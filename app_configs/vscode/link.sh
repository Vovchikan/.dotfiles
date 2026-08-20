#!/usr/bin/env bash

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 1

USER_DIR="$SCRIPT_DIR/.config/Code/User"
mkdir -p "$HOME/.config/Code/User"
ln -vs --target-directory="$HOME/.config/Code/User" "$USER_DIR/settings.json"
ln -vs --target-directory="$HOME/.config/Code/User" "$USER_DIR/keybindings.json"
