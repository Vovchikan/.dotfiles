#!/usr/bin/env bash

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 1

ln -vs --target-directory="$HOME/.config" "$SCRIPT_DIR/.config/mc"

# Do not track changes in some files
pushd "$SCRIPT_DIR"
git-hide "$SCRIPT_DIR/.config/mc/panels.ini"
git-hide "$SCRIPT_DIR/.config/mc/ini"
popd

# for item in "$SCRIPT_DIR/.config/mc"/*; do
#   ln -s --target-directory="$MC_DIR" $item
# done
