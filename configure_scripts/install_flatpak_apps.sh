#!/usr/bin/env bash

check_deps() {
  if ! command -v flatpak &> /dev/null; then
    echo "flatpak could not be found"
    exit 1
  fi
}


configure_flatpak() {
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  flatpak remote-add --if-not-exists --subset=verified flathub-verified https://flathub.org/repo/flathub.flatpakrepo
}

install() {
  flatpak install --system flathub \
    org.keepassxc.KeePassXC \
    org.qbittorrent.qBittorrent \
    io.dbeaver.DBeaverCommunity \
    com.tomjwatson.Emote
}

check_deps

configure_flatpak
install
