#!/usr/bin/env bash

check_requirements() {
  # asdf plugin requirements
  for app in asdf dirmngr gpg curl gawk; do
    if ! command -v $app &> /dev/null; then
      echo "${app} could not be found"
      exit 1
    fi
  done
}

install() {
  export KERL_BUILD_DOCS=yes
  asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git
  asdf install elixir 1.14.2-otp-25
  asdf global elixir 1.14.2-otp-25
}

default_mix_commands() {
  echo "local.hex
local.rebar
archive.install hex phx_new" > $HOME/.default-mix-commands
}

check_requirements
default_mix_commands
install
