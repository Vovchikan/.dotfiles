#!/usr/bin/env bash

# https://rust-lang.org/ru/learn/get-started/

set -Eeuo pipefail

source "$MYSCRIPTS/tools/utils.sh"

# "программа|ответ_по_умолчанию|зависимости|аргументы_cargo"
# "example|n|cmake,openssl|--locked,--no-default-features"
CARGO_TOOLS=(
  # https://github.com/terror/just-lsp
  "just-lsp|n||"
  # https://docs.deno.com/runtime/getting_started/installation/
  # Need for https://github.com/yt-dlp/yt-dlp/wiki/EJS
  "deno|y|cmake,pkg:clang,pkg:libclang-dev,pkg:libglib2.0-dev|--locked"
)

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

ask_install_cargo_tool() {
  local command="$1"
  local default_answer="$2"
  local dependencies="$3"
  local cargo_options="$4"

  local dependency_args=()
  local cargo_args=()
  local prompt
  local response

  if command -v "$command" &> /dev/null; then
    echo "✅ $command already installed"
    "$command" --version
    return 0
  fi

  case "${default_answer,,}" in
    y) prompt="[Y/n]" ;;
    n) prompt="[y/N]" ;;
    *)
      echo "❌ Invalid default answer '$default_answer' for $command" >&2
      return 1
      ;;
  esac

  echo
  read -r -p "Install $command? $prompt " response

  if [[ "${default_answer,,}" == "y" ]]; then
    if [[ -n "$response" && ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
      return 0
    fi
  elif [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    return 0
  fi

  if [[ -n "$dependencies" ]]; then
    IFS=',' read -ra dependency_args <<< "$dependencies"
  fi

  if [[ -n "$cargo_options" ]]; then
    IFS=',' read -ra cargo_args <<< "$cargo_options"
  fi

  check_dependencies cargo pkg:build-essential "${dependency_args[@]}"
  cargo install "$command" "${cargo_args[@]}"
}

ask_install_cargo

for tool in "${CARGO_TOOLS[@]}"; do
  IFS='|' read -r command default_answer dependencies cargo_options <<< "$tool"

  ask_install_cargo_tool \
    "$command" \
    "$default_answer" \
    "$dependencies" \
    "$cargo_options"
done
