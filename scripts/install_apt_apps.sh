#!/usr/bin/env bash

check_deps() {
  if ! command -v apt &> /dev/null; then
    echo "apt could not be found"
    exit 1
  fi
}

install_openconnect() {
  # with core plugin
  sudo apt install -y openconnect network-manager-openconnect

  # plugin for gnome
  #sudo apt install -y network-manager-openconnect
}

check_deps

install_openconnect
