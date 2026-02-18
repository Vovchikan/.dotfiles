#!/usr/bin/env bash

echo "This script need refactoring"
exit 1

mkdir -pv ~/dvp/elixir
mkdir -pv ~/dvp/sql
mkdir -pv ~/dvp/work

mkdir -pv ~/Downloads/Firefox
mkdir -pv ~/Downloads/Torrent
mkdir -pv ~/Downloads/Telegram
mkdir -pv ~/Downloads/Vivaldi
mkdir -pv ~/Downloads/Chromium

mkdir -pv ~/Documents/keepassxc

# /mnt/data
ln -s --target-directory=~ /mnt/data/mnt/data ntfs-data
ln -s --target-directory=~ /mnt/data/Media/Videos
# /mnt/multihome-data
ln -s --target-directory=~ /mnt/multihome-data
ln -s --target-directory=~ /mnt/multihome-data/repos/dotfiles
