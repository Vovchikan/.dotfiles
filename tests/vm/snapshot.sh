#!/usr/bin/env bash
set -Eeuo pipefail

SNAPSHOT_NAME="${SNAPSHOT_NAME:-clean}"

usage() {
  echo "Usage: $0 <create|revert|has|delete> <vm-name>"
  echo "  create  — create snapshot '$SNAPSHOT_NAME' (VM must be running)"
  echo "  revert  — revert to snapshot and start VM"
  echo "  has     — exit 0 if snapshot exists, 1 otherwise"
  echo "  delete  — remove snapshot"
  exit 1
}

[ $# -lt 2 ] && usage

ACTION="$1"
VM_NAME="$2"

case "$ACTION" in
  create)
    echo "Creating snapshot '$SNAPSHOT_NAME' for $VM_NAME..."
    virsh snapshot-create-as "$VM_NAME" "$SNAPSHOT_NAME" \
      "Clean state after initial setup" >/dev/null
    echo "  done"
    ;;

  revert)
    echo "Reverting $VM_NAME to snapshot '$SNAPSHOT_NAME'..."
    virsh snapshot-revert "$VM_NAME" "$SNAPSHOT_NAME" --running >/dev/null 2>&1 || \
      virsh snapshot-revert "$VM_NAME" "$SNAPSHOT_NAME" >/dev/null
    echo "  done"
    ;;

  has)
    if virsh snapshot-list "$VM_NAME" --name 2>/dev/null | grep -qx "$SNAPSHOT_NAME"; then
      exit 0
    fi
    exit 1
    ;;

  delete)
    echo "Deleting snapshot '$SNAPSHOT_NAME' for $VM_NAME..."
    virsh snapshot-delete "$VM_NAME" "$SNAPSHOT_NAME" --metadata >/dev/null 2>&1 || true
    echo "  done"
    ;;

  *)
    usage
    ;;
esac
