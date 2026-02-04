#!/usr/bin/env bash

check_requirements() {
  for app in asdf dirmngr gpg curl gawk; do
    if ! command -v $app &> /dev/null; then
      echo "${app} could not be found"
      exit 1
    fi
  done
}

install() {
  asdf plugin-add nodejs
  asdf install nodejs 18.19.0
  asdf global nodejs 18.19.0
}

check_requirements
install
