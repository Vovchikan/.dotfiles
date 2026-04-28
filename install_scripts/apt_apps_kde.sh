#!/usr/bin/env bash

source "$MYSCRIPTS/tools/utils.sh"

check_dependencies apt

install() {

  # Flatpak
  if command -v flatpak &> /dev/null; then
    sudo apt plasma-discover-backend-flatpak \
      pavucontrol
  fi
}

install
