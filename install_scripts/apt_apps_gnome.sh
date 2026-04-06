#!/usr/bin/env bash


source "$MYSCRIPTS/utils.sh"

check_dependencies apt

install() {

  # openconnect with core plugin
  sudo apt install -y gnome-tweaks \
    network-manager-openconnect-gnome \
    gnome-shell-extension-manager \
    gir1.2-gtop-2.0 lm-sensors

  # ubuntu-restricted-extras нужен для проприетарных кодеков и шрифтов
  ## mp3, aac, avc, h.264, Microsoft Fonts, unrar
  # gnome-tweaks нужен для настройки смены языка через shift + alt
  # gnome-shell-extension-manager нужен для установки расширений в панель
  ## например показания температуры cpu gpu через Vitals (https://github.com/corecoding/Vitals)
  # gir1.2-gtop-2.0 lm-sensors нужны для Vitals
}

install
