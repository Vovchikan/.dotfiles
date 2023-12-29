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

  software

  echo
  read -r -p "Install langs? [y/N] " response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
  then
    langs
  fi

  $script_dir/install_fonts.sh
}

function software() {

  echo
  echo "+---------------------------------+"
  echo "|        Installing apps          |"
  echo "|            from apt             |"
  echo "+---------------------------------+"
  echo
  $script_dir/install_apt_apps.sh

  echo
  echo "+---------------------------------+"
  echo "|        Installing nix           |"
  echo "+---------------------------------+"
  echo
  $script_dir/install_nix.sh

  echo
  echo "+-------------------------------+"
  echo "|        Installing asdf        |"
  echo "+-------------------------------+"
  echo
  $script_dir/install_asfd.sh

  echo
  echo "+---------------------------------+"
  echo "|        Installing rclone        |"
  echo "+---------------------------------+"
  echo
  $script_dir/install_rclone.sh

}

function langs () {

  echo
  echo "+---------------------------------+"
  echo "|        Installing NodeJS        |"
  echo "+---------------------------------+"
  echo
  $script_dir/install_asdf_nodejs.sh


  echo
  echo "+---------------------------------+"
  echo "|        Installing Erlang        |"
  echo "+---------------------------------+"
  echo
  $script_dir/install_asdf_erlang.sh


  echo
  echo "+---------------------------------+"
  echo "|        Installing Elixir        |"
  echo "+---------------------------------+"
  echo
  $script_dir/install_asdf_elixir.sh

}

main
