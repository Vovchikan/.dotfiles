#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 1
DPATH="$SCRIPT_DIR/.." # install_scripts -> dotfiles
source "$DPATH/scripts/utils.sh"

set -Eeuo pipefail

function main() {
  $SCRIPT_DIR/apt_apps.sh
  $SCRIPT_DIR/asdf.sh
  $SCRIPT_DIR/yt-dlp.sh
  $SCRIPT_DIR/docker_desktop_ubuntu.sh
  # $SCRIPT_DIR/create_dirs.sh

  software
}

function software() {

  echo
  read -r -p "Install snap apps? [y/N] " response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
  then
    sudo snap install tldr
  fi

  echo
  read -r -p "Install postgres? [y/N] " response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
  then
    sudo apt install postgresql postgresql-doc
  fi

  echo
  read -r -p "Install App for Razer Devices? [y/N] " response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
  then
    $SCRIPT_DIR/razer.sh
  fi

  echo
  read -r -p "Install apps for qemu (VM)? [y/N] " response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
  then
    sudo apt install -y qemu-kvm bridge-utils virt-manager
  fi

}

main
