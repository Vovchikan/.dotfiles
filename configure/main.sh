#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 1

set -Eeuo pipefail

main () {
  $SCRIPT_DIR/git.sh
  $SCRIPT_DIR/gitk.sh
}

update-default-editor () {
  sudo update-alternatives --config editor
}

main
update-default-editor

echo
read -r -p "Copy fonts? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
  $SCRIPT_DIR/copy_fonts.sh
fi