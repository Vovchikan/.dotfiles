#!/usr/bin/env bash

check_requirements() {
  if ! command -v curl &> /dev/null; then
    echo "curl could not be found"
    exit 1
  fi

  if command -v nix &> /dev/null; then
    echo "nix already installed"
    exit 0
  fi
}

check_requirements

# install nix (multi-user)
sh <(curl -L https://nixos.org/nix/install) --daemon

