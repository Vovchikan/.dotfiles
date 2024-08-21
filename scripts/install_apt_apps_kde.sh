#!/usr/bin/env bash

check_requirements() {
  if ! command -v apt &> /dev/null; then
    echo "apt could not be found"
    exit 1
  fi
}

install() {

  # Flatpak
  sudo apt plasma-discover-backend-flatpak
}

check_requirements
install
