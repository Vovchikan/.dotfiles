#!/usr/bin/env bash

set -Eeuo pipefail
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

ln -s --target-directory=$HOME $script_dir/.vim
ln -s --target-directory=$HOME $script_dir/.vimrc
