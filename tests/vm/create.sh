#!/usr/bin/env bash
set -Eeuo pipefail

VM_NAME="dotfiles-test"
VM_TYPE="headless"
RAM=4096
CPUS=4
DISK_SIZE=30G
GRAPHICS="--graphics none"
SSH_KEY="${SSH_KEY:-$HOME/.ssh/id_ed25519.pub}"
CLOUD_IMAGE_URL="https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
CACHE_DIR="$HOME/.cache/dotfiles-test"
IMAGES_DIR="${IMAGES_DIR:-/var/lib/libvirt/images}"

while [ $# -gt 0 ]; do
  case "$1" in
    --desktop)
      VM_NAME="dotfiles-test-desktop"
      VM_TYPE="desktop"
      RAM=8192
      DISK_SIZE=80G
      GRAPHICS="--graphics spice,listen=0.0.0.0"
      shift ;;
    --name) VM_NAME="$2"; shift 2 ;;
    --help) echo "Usage: $0 [--desktop] [--name <name>]"; exit 0 ;;
    *) echo "Unknown: $1"; exit 1 ;;
  esac
done

if virsh list --all --name | grep -qx "$VM_NAME"; then
  echo "VM '$VM_NAME' already exists. Destroy it first: tests/vm/destroy.sh $VM_NAME"
  exit 1
fi

if [ ! -f "$SSH_KEY" ]; then
  echo "SSH key not found: $SSH_KEY"
  echo "Set SSH_KEY env var or generate a key: ssh-keygen -t ed25519"
  exit 1
fi

mkdir -p "$CACHE_DIR"
sudo mkdir -p "$IMAGES_DIR"

# Download cloud image (user-local cache, accessible only to user)
CLOUD_IMAGE="$CACHE_DIR/noble-server-cloudimg-amd64.img"
if [ ! -f "$CLOUD_IMAGE" ]; then
  echo "Downloading Ubuntu 24.04 cloud image..."
  curl -Lo "$CLOUD_IMAGE" "$CLOUD_IMAGE_URL"
  qemu-img info "$CLOUD_IMAGE" | head -3
fi

# Copy cloud image to libvirt images dir (QEMU needs access)
BASE_IMAGE="$IMAGES_DIR/noble-server-cloudimg-amd64.img"
if [ ! -f "$BASE_IMAGE" ]; then
  sudo cp "$CLOUD_IMAGE" "$BASE_IMAGE"
  sudo chown "root:libvirt" "$BASE_IMAGE"
  sudo chmod 644 "$BASE_IMAGE"
fi

VM_IMAGE="$IMAGES_DIR/$VM_NAME.qcow2"
echo "Creating disk image: $VM_IMAGE ($DISK_SIZE)"
sudo qemu-img create -F qcow2 -b "$BASE_IMAGE" -f qcow2 "$VM_IMAGE" "$DISK_SIZE"
sudo chown "$USER:libvirt" "$VM_IMAGE"

# cloud-init user-data
cat > "/tmp/$VM_NAME-user-data" <<EOF
#cloud-config
users:
  - name: testuser
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - $(cat "$SSH_KEY")
packages:
  - qemu-guest-agent
  - python3
  - git
EOF

if [ "$VM_TYPE" = "desktop" ]; then
  cat >> "/tmp/$VM_NAME-user-data" <<EOF
  - kde-plasma-desktop
  - konsole
  - dolphin
  - pavucontrol
  - spice-vdagent
  - plasma-discover-backend-flatpak
EOF
fi

cat >> "/tmp/$VM_NAME-user-data" <<EOF
chpasswd:
  list: testuser:testuser
  expire: False
runcmd:
  - snap install --edge --classic just
EOF

if [ "$VM_TYPE" = "desktop" ]; then
  cat >> "/tmp/$VM_NAME-user-data" <<EOF
  - systemctl set-default graphical.target
EOF
fi

# cloud-init meta-data
cat > "/tmp/$VM_NAME-meta-data" <<EOF
instance-id: $VM_NAME
local-hostname: $VM_NAME
EOF

# Build seed ISO with correct filenames (cloud-init expects user-data / meta-data)
SEED_DIR="/tmp/$VM_NAME-seed"
mkdir -p "$SEED_DIR"
cp "/tmp/$VM_NAME-user-data" "$SEED_DIR/user-data"
cp "/tmp/$VM_NAME-meta-data" "$SEED_DIR/meta-data"

SEED_IMAGE="$IMAGES_DIR/$VM_NAME-seed.iso"
sudo genisoimage -output "$SEED_IMAGE" -volid cidata -joliet -rock "$SEED_DIR" >/dev/null 2>&1
sudo chown "$USER:libvirt" "$SEED_IMAGE"
rm -rf "$SEED_DIR" "/tmp/$VM_NAME-user-data" "/tmp/$VM_NAME-meta-data"

virt-install \
  --name "$VM_NAME" \
  --ram "$RAM" \
  --vcpus "$CPUS" \
  --disk "$VM_IMAGE" \
  --disk "$SEED_IMAGE,device=cdrom" \
  --os-variant ubuntu24.04 \
  --network default \
  $GRAPHICS \
  --import \
  --noautoconsole \
  --wait=0

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
SNAPSHOT_SCRIPT="$SCRIPT_DIR/snapshot.sh"

echo "Waiting for VM to boot and get IP..."
for i in $(seq 1 60); do
  IP=$(virsh domifaddr "$VM_NAME" 2>/dev/null | grep -oP '\d+\.\d+\.\d+\.\d+' | head -1) || true
  [ -n "$IP" ] && break
  sleep 2
done

if [ -z "$IP" ]; then
  echo "VM '$VM_NAME' created, but IP not detected yet."
  echo "Check IP: virsh domifaddr $VM_NAME"
  echo "Connect: ssh testuser@<ip>"
  exit 0
fi

echo "VM '$VM_NAME' is at $IP"

if [ "$VM_TYPE" = "desktop" ]; then
  echo
  echo "Waiting for cloud-init to install KDE Plasma (5-15 min)..."
  echo "Connect to virt-manager to watch the progress, or grab a coffee."
  echo
  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    "testuser@$IP" "cloud-init status --wait" </dev/null
  echo "cloud-init finished."

  echo "Creating clean snapshot..."
  bash "$SNAPSHOT_SCRIPT" create "$VM_NAME"

  echo "Shutting down VM for snapshot stability..."
  virsh shutdown "$VM_NAME" >/dev/null 2>&1
  while virsh list --name | grep -qx "$VM_NAME"; do sleep 1; done
  echo
  echo "Desktop VM ready. Next runs will revert to snapshot (fast)."
  echo "Graphical console: virt-manager → open '$VM_NAME'"
fi

echo "Connect: ssh testuser@$IP"
