#!/usr/bin/env bash

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 1

ln -vs --target-directory=$HOME $SCRIPT_DIR/.tmux
ln -vs --target-directory=$HOME $SCRIPT_DIR/.tmux.conf
