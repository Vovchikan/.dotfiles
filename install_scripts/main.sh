#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 1
DPATH="$SCRIPT_DIR/.." # install_scripts -> dotfiles
source "$DPATH/scripts/tools/utils.sh"

set -Eeuo pipefail

function main() {
  sudo apt update && sudo apt upgrade -y

  $SCRIPT_DIR/apt_apps.sh
  $SCRIPT_DIR/asdf.sh
  $SCRIPT_DIR/cargo.sh
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
  read -r -p "Install amdgpu_top? [y/N] " response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
  then
    $SCRIPT_DIR/amdgpu_top.sh
  fi

  echo
  read -r -p "Install apps for qemu (VM)? [y/N] " response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
  then
    sudo apt install -y qemu-kvm bridge-utils virt-manager
  fi

  echo
  read -r -p "Install codecs? [y/N] " response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
  then
    sudo apt install ubuntu-restricted-extras
  fi
}

main
