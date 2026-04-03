#!/usr/bin/env bash

source "$MYSCRIPTS/utils.sh"

check_dependencies apt

install() {

  # main apps
  sudo apt install -y build-essential curl git gitk \
    procps unzip screen htop xclip imagemagick \
    ca-certificates openssh-server \
    mc p7zip-full catdoc unrar antiword mplayer

  # drivers for harware decoding on amd video card
  sudo apt install -y va-driver-all

  # for yt-dlp
  sudo apt install -y ffmpeg

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
  sudo apt install -y gnome-terminal pass

  # requirements: Ubuntu >= 22.04
  # Change mouse key bindings https://github.com/sezanzeb/input-remapper
  sudo apt install input-remapper

  # https://github.com/TheTumultuousUnicornOfDarkness/CPU-X?tab=readme-ov-file#from-repositories
  sudo apt install cpu-x
}

install
