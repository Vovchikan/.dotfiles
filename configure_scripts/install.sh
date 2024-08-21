#!/usr/bin/env bash

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
DPATH="$script_dir/.." # configure_scripts -> .dotfiles

set -Eeuo pipefail

function main() {

  echo
  read -r -p "Rename default dirs to en? [y/N] " response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
  then
    rename-dirs
  fi

  $script_dir/install_apt_apps.sh
  $script_dir/configure_git.sh
  $script_dir/configure_gitka.sh
  # $script_dir/create_dirs.sh

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

  echo
  read -r -p "Install docker for Ubuntu? [y/N] " response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
  then
    $script_dir/install_docker_desktop_ubuntu.sh
  fi

  echo
  read -r -p "Copy fonts? [y/N] " response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
  then
    $script_dir/copy_fonts.sh
  fi
}

function software() {

  echo
  read -r -p "Install asdf? [y/N] " response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
  then
    $script_dir/install_asdf.sh
  fi

  echo
  read -r -p "Install postgres? [y/N] " response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
  then
    sudo apt install postgresql postgresql-doc
  fi

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

function rename-dirs() {
  cp -f --backup=numbered ~/.config/user-dirs.dirs
  cp -f --backup=numbered ~/.config/user-dirs.locale
  LC_ALL=C.UTF-8 xdg-user-dirs-update --force
}

main
