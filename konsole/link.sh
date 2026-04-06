#!/usr/bin/env bash

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 1

WHERE_DIR=".local/share/konsole"
ln -vs --target-directory="$HOME/$WHERE_DIR" "$SCRIPT_DIR/$WHERE_DIR/MyDefault.profile"
