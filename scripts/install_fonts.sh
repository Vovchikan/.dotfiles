#!/usr/bin/env bash

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
DPATH="$script_dir/.." # scripts -> .dotfiles

set -Eeuo pipefail


echo
echo "+---------------------------------+"
echo "|        Installing fonts         |"
echo "+---------------------------------+"
echo
if [ -d "~/.local/share/fonts" ]; then
  mkdir ~/.local/share/fonts
fi
for font_dir in "$DPATH/fonts"*
do
  cp -r "${font_dir}" ~/.local/share/fonts
done
fc-cache -fv # Update font cache
