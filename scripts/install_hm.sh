#!/usr/bin/env bash

check_deps() {
  if ! command -v nix &> /dev/null; then
    echo "curl could not be found"
    exit 1
  fi
}

check_deps

# !!! Nix won't work in active shell sessions until you restart them !!!
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update

nix-shell '<home-manager>' -A install

echo ". \"$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh\"" >> ~/.profile

# make backups of old home.nix
mkdir -p $HOME/backups
mv $HOME/.config/home-manager/home.nix $HOME/backups
echo "Make symbolic link for home-manager"
ln -s --target-directory=$HOME/.config/home-manager \
  $HOME/.dotfiles/home.nix

home-manager switch
