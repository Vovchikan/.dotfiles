#!/usr/bin/env bash

source "$MYSCRIPTS/utils.sh"

check_dependencies flatpak

configure_flatpak() {
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  flatpak remote-add --if-not-exists --subset=verified flathub-verified https://flathub.org/repo/flathub.flatpakrepo
}

install() {
  flatpak install --system flathub \
    org.keepassxc.KeePassXC \
    org.qbittorrent.qBittorrent \
    com.tomjwatson.Emote
}

configure_flatpak
install
