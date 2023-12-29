#!/usr/bin/env bash

check_requirements() {
  if ! command -v curl &> /dev/null; then
    echo "curl could not be found"
    exit 1
  fi

  if ! command -v git &> /dev/null; then
    echo "git could not be found"
    exit 1
  fi

  if command -v asdf &> /dev/null; then
    echo "asdf already installed"
    exit 0
  fi
}

install() {
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.13.1
  echo -e "\n. \"$HOME/.asdf/asdf.sh\"" >> ~/.bash_profile
  echo -e "\n. \"$HOME/.asdf/completions/asdf.bash\"" >> ~/.bash_profile
}

check_requirements
install

echo "

  Please reboot system, or source ~/.bash_profile for
adding asdf to PATH variable.

"
