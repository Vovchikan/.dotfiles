#!/usr/bin/env bash

check_requirements() {
  if ! command -v apt &> /dev/null; then
    echo "apt could not be found"
    exit 1
  fi
}

install() {

  # main apps
  sudo apt install -y build-essential curl git gitk unzip

  # openconnect with core plugin
  sudo apt install -y openconnect network-manager-openconnect

  # For Phoenix framework
  sudo apt install -y inotify-tools

  # For asdf plugins
  sudo apt install -y dirmngr gpg curl gawk

  # Flatpak
  sudo apt install -y flatpak

  # Docker
  sudo apt install -y gnome-terminal
}

check_requirements
install
