#!/usr/bin/env bash

check_deps() {
  if ! command -v nix &> /dev/null; then
    echo "nix could not be found"
    exit 1
  fi
}

check_deps

# !!! Nix won't work in active shell sessions until you restart them !!!
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update

nix-shell '<home-manager>' -A install

echo ". \"$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh\"" >> ~/.profile