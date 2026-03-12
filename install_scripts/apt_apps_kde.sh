#!/usr/bin/env bash

source "$MYSCRIPTS/utils.sh"

check_dependencies apt

install() {

  # Flatpak
  if command -v flatpak &> /dev/null; then
    sudo apt plasma-discover-backend-flatpak
  fi
}

install
