#!/usr/bin/env bash

check_deps() {
  if ! command -v apt &> /dev/null; then
    echo "apt could not be found"
    exit 1
  fi
}


install_configure_flatpak() {
  sudo apt install -y flatpak

  # add system flathub
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  flatpak remote-add --if-not-exists --subset=verified flathub-verified https://flathub.org/repo/flathub.flatpakrepo

  # add user flathub
  flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  flatpak remote-add --user --if-not-exists --subset=verified flathub-verified https://flathub.org/repo/flathub.flatpakrepo

  # flatpak backend for plugin manager
  sudo apt install plasma-discover-backend-flatpak
}

install_apps() {
  if ! command -v flatpak &> /dev/null; then
    echo "flatpak not isntalled"
    exit 1
  fi

  flatpak install com.getpostman.Postman org.keepassxc.KeePassXC org.qbittorrent.qBittorrent
}

check_deps

install_configure_flatpak
install_apps
