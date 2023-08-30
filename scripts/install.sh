#!/usr/bin/env bash

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
DPATH="$script_dir/.." # scripts -> .dotfiles

set -Eeuo pipefail

function main() {

  software

  echo
  echo "+---------------------------------+"
  echo "|       Download submodules       |"
  echo "+---------------------------------+"
  echo
  git submodule update --recursive --init

  echo
  read -r -p "Install langs? [y/N] " response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
  then
    langs
  fi

  $script_dir/configs.sh

  echo
  echo "+---------------------------------+"
  echo "|   Download tmux plug manager    |"
  echo "|       and all tmux plugins      |"
  echo "+---------------------------------+"
  echo
  if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && \
      ~/.tmux/plugins/tpm/bin/install_plugins
  fi
}

function software() {

  if [ -f "~/.bash_profile" ]; then
    mv -v ~/.bash_profile ~/.bash_profile.backup
  fi
  cp -v $DPATH/templates/bash_profile.template ~/.bash_profile

  echo
  echo "+---------------------------------+"
  echo "|        Installing curl git      |"
  echo "|     build-essential coreutils   |"
  echo "+---------------------------------+"
  echo
  sudo apt install -y build-essential curl git

  echo
  echo "+---------------------------------+"
  echo "|        Installing nix           |"
  echo "+---------------------------------+"
  echo
  sh <(curl -L https://nixos.org/nix/install) --daemon

  echo
  echo "+---------------------------------+"
  echo "|   Installing nvim vim htop      |"
  echo "|          neofetch stow          |"
  echo "+---------------------------------+"
  echo
  nix-env -iA nixpkgs.neovim
  nix-env -iA nixpkgs.vim
  nix-env -iA nixpkgs.htop
  nix-env -iA nixpkgs.stow
  nix-env -iA nixpkgs.neofetch

  echo
  echo "+-------------------------------+"
  echo "|        Installing asdf        |"
  echo "+-------------------------------+"
  echo
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.12.0
  echo -e "\n. \"$HOME/.asdf/asdf.sh\"" >> ~/.bash_profile
  echo -e "\n. \"$HOME/.asdf/completions/asdf.bash\"" >> ~/.bash_profile

  echo
  echo "+---------------------------------+"
  echo "|        Installing rclone        |"
  echo "+---------------------------------+"
  echo
  # Installing rclone with ignoring all errors -> || true
  curl https://rclone.org/install.sh | (sudo bash || true)

  echo
  echo "+---------------------------------+"
  echo "|        Installing gitk          |"
  echo "+---------------------------------+"
  echo
  sudo apt install gitk

}

function langs () {

  echo
  echo "+---------------------------------+"
  echo "|        Installing NodeJS        |"
  echo "+---------------------------------+"
  echo
  asdf plugin-add nodejs
  asdf install nodejs 16.13.0
  asdf global nodejs 16.13.0


  echo
  echo "+---------------------------------+"
  echo "|        Installing Erlang        |"
  echo "+---------------------------------+"
  echo
  sudo apt install -y build-essential autoconf m4 libncurses5-dev libwxgtk3.0-gtk3-dev libwxgtk-webview3.0-gtk3-dev libgl1-mesa-dev libglu1-mesa-dev libpng-dev libssh-dev unixodbc-dev xsltproc fop libxml2-utils libncurses-dev openjdk-11-jdk
  asdf plugin-add erlang
  asdf install erlang 25.3.2.5
  asdf global erlang 25.3.2.5


  echo
  echo "+---------------------------------+"
  echo "|        Installing Elixir        |"
  echo "+---------------------------------+"
  echo
  sudo apt install -y unzip
  asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git
  asdf install elixir 1.14.1-otp-25
  asdf global elixir 1.14.1-otp-25

  # This need for Phoenix framework
  echo
  echo "+---------------------------------+"
  echo "|      Installing inotify-tools   |"
  echo "+---------------------------------+"
  echo
  sudo apt install inotify-tools

}

main
