#!/usr/bin/env bash
set -Eeuo pipefail

IMAGES_DIR="${IMAGES_DIR:-/var/lib/libvirt/images}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
SNAPSHOT_SCRIPT="$SCRIPT_DIR/snapshot.sh"

destroy_vm() {
  local name="$1"
  echo "Destroying VM: $name"
  virsh destroy "$name" 2>/dev/null && echo "  powered off" || echo "  not running"
  bash "$SNAPSHOT_SCRIPT" delete "$name" 2>/dev/null || true
  virsh undefine "$name" --nvram 2>/dev/null && echo "  undefined" || true
  sudo rm -f "$IMAGES_DIR/$name.qcow2" "$IMAGES_DIR/$name-seed.iso"
  echo "  disks removed"
}

if [ "${1:-}" = "--all" ]; then
  for vm in dotfiles-test dotfiles-test-desktop; do
    destroy_vm "$vm"
  done
elif [ -n "${1:-}" ]; then
  destroy_vm "$1"
else
  echo "Usage: $0 <vm-name> | --all"
  echo "  Default VMs: dotfiles-test, dotfiles-test-desktop"
  exit 1
fi
