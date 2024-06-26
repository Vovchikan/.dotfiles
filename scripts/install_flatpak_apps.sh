#!/usr/bin/env bash

check_deps() {
  if ! command -v flatpak &> /dev/null; then
    echo "flatpak could not be found"
    exit 1
  fi
}


configure_flatpak() {
  # add system flathub
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  flatpak remote-add --if-not-exists --subset=verified flathub-verified https://flathub.org/repo/flathub.flatpakrepo

  # add user flathub
  flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  flatpak remote-add --user --if-not-exists --subset=verified flathub-verified https://flathub.org/repo/flathub.flatpakrepo

}

install_user_apps() {
  flatpak install --user flathub \
    com.getpostman.Postman \
    org.keepassxc.KeePassXC \
    org.qbittorrent.qBittorrent
}

install_user_apps() {
  flatpak install --system flathub \
    com.tomjwatson.Emote \
    org.mozilla.Thunderbird
}

check_deps

configure_flatpak
install_user_apps
install_system_apps
