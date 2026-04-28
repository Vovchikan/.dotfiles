#!/usr/bin/env bash

# https://asdf-vm.com/guide/getting-started.html

# if command -v asdf &> /dev/null; then
#   echo "asdf already installed"
#   exit 0
# fi

ASDF_VERSION="v0.18.1"

set -Eeuo pipefail
source "$MYSCRIPTS/tools/utils.sh"

ask_install_asdf() {
  if command -v asdf &> /dev/null; then
    echo "✅ asdf already installed"
    asdf --version
    return 0
  fi

  echo
  read -r -p "Install asdf? [y/N] " response
  if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    exit 0
  fi

  check_dependencies git wget

  TMP_DIR=$(mktemp -d)
  pushd "$TMP_DIR"

  wget "https://github.com/asdf-vm/asdf/releases/download/${ASDF_VERSION}/asdf-${ASDF_VERSION}-linux-amd64.tar.gz"
  tar -xzf "asdf-${ASDF_VERSION}-linux-amd64.tar.gz"
  mkdir -p "$HOME/.asdf/bin"
  mv asdf "$HOME/.asdf/bin/"

  # Добавление в PATH, если еще не добавлено
  if ! grep -q 'asdf' "$HOME/.bashrc"; then
    printf "\n\n" >> "$HOME/.bashrc"
    echo 'export PATH="$HOME/.asdf/bin:$PATH"' >> "$HOME/.bashrc"
    echo 'export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"' >> "$HOME/.bashrc"
    echo '. <(asdf completion bash)' >> "$HOME/.bashrc"
  fi

  popd
  rm -rf "$TMP_DIR"

  export PATH="$HOME/.asdf/bin:$PATH"
  export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
  asdf --version

  echo "⚠️ Please run 'source ~/.bashrc' or restart your terminal to use asdf"
}

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

  check_dependencies gpg gawk curl asdf dirmngr

  echo
  echo "+---------------------------------+"
  echo "|        Installing Deno          |"
  echo "+---------------------------------+"
  echo
  asdf plugin add deno https://github.com/asdf-community/asdf-deno.git
  asdf install deno latest
  asdf set --home deno latest
  deno --version
}

ask_install_nodejs() {
  if command -v node &> /dev/null; then
    echo "✅ nodejs already installed"
    node --version
    return 0
  fi

  echo
  read -r -p "Install nodejs? [Y/n] " response
  if [[ -n "$response" && ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    return 0
  fi

  check_dependencies gpg gawk curl asdf dirmngr

  echo
  echo "+---------------------------------+"
  echo "|        Installing NodeJS        |"
  echo "+---------------------------------+"
  echo
  asdf plugin add nodejs
  asdf install nodejs 18.19.0
  asdf set --home nodejs 18.19.0
  node --version
}

ask_install_erlang() {
  if command -v erl &> /dev/null; then
    echo "✅ Erlang already installed"
    erl -version
    return 0
  fi

  echo
  read -r -p "Install Erlang? [Y/n] " response
  if [[ -n "$response" && ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    return 0
  fi

  check_dependencies apt gpg gawk curl asdf dirmngr

  echo
  echo "+---------------------------------+"
  echo "|        Installing Erlang        |"
  echo "+---------------------------------+"
  echo
  sudo apt install -y build-essential autoconf m4 libncurses-dev libwxgtk3.2-dev libwxgtk-webview3.2-dev libgl1-mesa-dev libglu1-mesa-dev libpng-dev libssh-dev unixodbc-dev xsltproc fop libxml2-utils libncurses-dev openjdk-17-jdk
  export KERL_BUILD_DOCS=yes
  asdf plugin add erlang
  asdf install erlang 27.1.3
  asdf set --home erlang 27.1.3
  erl -version
}

default_mix_commands() {
  echo "local.hex
local.rebar
archive.install hex phx_new" > $HOME/.default-mix-commands
}

ask_install_elixir() {
  if command -v iex &> /dev/null; then
    echo "✅ Elixir already installed"
    iex --version
    return 0
  fi

  echo
  read -r -p "Install Elixir? [Y/n] " response
  if [[ -n "$response" && ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    return 0
  fi

  check_dependencies apt gpg gawk curl asdf dirmngr

  echo
  echo "+---------------------------------+"
  echo "|        Installing Elixir        |"
  echo "+---------------------------------+"
  echo
  default_mix_commands
  export KERL_BUILD_DOCS=yes
  asdf plugin add elixir https://github.com/asdf-vm/asdf-elixir.git
  asdf install elixir 1.17.3-otp-27
  asdf set --home elixir 1.17.3-otp-27
  iex --version
}

ask_install_asdf
ask_install_deno
ask_install_nodejs
ask_install_erlang
ask_install_elixir
