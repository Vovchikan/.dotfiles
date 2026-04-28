#!/usr/bin/env bash

# https://rust-lang.org/ru/learn/get-started/

set -Eeuo pipefail

source "$MYSCRIPTS/tools/utils.sh"

# https://rust-lang.org/ru/tools/install/
ask_install_cargo() {
  if command -v cargo &> /dev/null; then
    echo "✅ cargo already installed"
    cargo --version
    return 0
  fi

  echo
  read -r -p "Install cargo? [y/N] " response
  if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    exit 0
  fi

  check_dependencies curl

  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

  source "$HOME/.cargo/env"
  cargo --version

  echo "⚠️ Please run 'source ~/.bashrc' or restart your terminal to use cargo"
}

# https://github.com/terror/just-lsp
ask_install_just-lsp() {
  if command -v just-lsp &> /dev/null; then
    echo "✅ just-lsp already installed"
    just-lsp --version
    return 0
  fi

  echo
  read -r -p "Install just-lsp? [y/N] " response
  if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    exit 0
  fi

  check_dependencies cargo
  cargo install just-lsp
}

# https://docs.deno.com/runtime/getting_started/installation/
ask_install_deno() {
  # Need for https://github.com/yt-dlp/yt-dlp/wiki/EJS
  if command -v deno &> /dev/null; then
    echo "✅ deno already installed"
    deno --version
    return 0
  fi

  echo
  read -r -p "Install deno? [Y/n] " response
  if [[ -n "$response" && ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    return 0
  fi
  check_dependencies cargo cmake
  cargo install deno --locked
  deno --version
}

ask_install_cargo
ask_install_just-lsp
# ask_install_deno

# for update
# rustup update