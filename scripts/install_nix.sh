#!/usr/bin/env bash

check_deps() {
  if ! command -v curl &> /dev/null; then
    echo "curl could not be found"
    exit 1
  fi
}

check_deps

# install nix (multi-user)
sh <(curl -L https://nixos.org/nix/install) --daemon

