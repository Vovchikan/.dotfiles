#!/usr/bin/env bash

check_requirements() {
  if ! command -v apt &> /dev/null; then
    echo "apt could not be found"
    exit 1
  fi
}

install() {

  # openconnect with core plugin
  sudo apt install -y network-manager-openconnect-gnome
}

check_requirements
install
