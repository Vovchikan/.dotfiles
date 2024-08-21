#!/usr/bin/env bash

check_requirements() {
  if ! command -v apt &> /dev/null; then
    echo "apt could not be found"
    exit 1
  fi
}

install() {

  # main apps
  sudo apt install -y build-essential curl git gitk \
    unzip screen htop xclip \
    ca-certificates openssh-server

  # configure ssh
  sudo apt install -y openssh-server
  # configure ssh connections in double commander?
  sudo apt install gvfs-backends gvfs-fuse

  # openconnect with core plugin
  sudo apt install -y openconnect network-manager-openconnect

  # For Phoenix framework
  sudo apt install -y inotify-tools

  # For asdf plugins
  sudo apt install -y dirmngr gpg curl gawk

  # Flatpak
  # sudo apt install -y flatpak

  # Docker
  sudo apt install -y gnome-terminal

  # Razer Daemon - https://openrazer.github.io/#download
  sudo apt install openrazer-meta
  # Razer gui https://github.com/z3ntu/RazerGenie?tab=readme-ov-file
  if [ "$(. /etc/os-release && echo "${PRETTY_NAME}")" = "Ubuntu 25.10" ]; then
    echo 'deb http://download.opensuse.org/repositories/hardware:/razer/xUbuntu_25.10/ /' | sudo tee /etc/apt/sources.list.d/hardware:razer.list
    curl -fsSL https://download.opensuse.org/repositories/hardware:razer/xUbuntu_25.10/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/hardware_razer.gpg > /dev/null
    sudo apt update
    sudo apt install razergenie
  else
      echo "Неподдерживаемая система RazerGenie"
      echo "https://github.com/z3ntu/RazerGenie?tab=readme-ov-file"
  fi

  # requirements: Ubuntu >= 22.04
  # Change mouse key bindings https://github.com/sezanzeb/input-remapper
  sudo apt install input-remapper

  # https://github.com/TheTumultuousUnicornOfDarkness/CPU-X?tab=readme-ov-file#from-repositories
  sudo apt install cpu-x
}

check_requirements
install
