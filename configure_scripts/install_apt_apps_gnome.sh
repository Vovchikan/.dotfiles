#!/usr/bin/env bash

check_requirements() {
  if ! command -v apt &> /dev/null; then
    echo "apt could not be found"
    exit 1
  fi
}

install() {

  # openconnect with core plugin
  sudo apt install -y network-manager-openconnect-gnome \
    gnome-tweaks ubuntu-restricted-extras \
    gnome-shell-extension-manager \
    gir1.2-gtop-2.0 lm-sensors

  # ubuntu-restricted-extras нужен для проприетарных кодеков и шрифтов
  ## mp3, aac, avc, h.264, Microsoft Fonts, unrar
  # gnome-tweaks нужен для настройки смены языка через shift + alt
  # gnome-shell-extension-manager нужен для установки расширений в панель
  ## например показания температуры cpu gpu через Vitals (https://github.com/corecoding/Vitals)
  # gir1.2-gtop-2.0 lm-sensors нужны для Vitals
}

check_requirements
install
