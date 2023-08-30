#!/usr/bin/env bash

echo "Make symbolic link for home-manager"
ln -s --target-directory=$HOME/.config/home-manager \
  $HOME/.dotfiles/home.nix
