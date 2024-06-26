#!/usr/bin/env bash

ERLANG_DEPS=(build-essential autoconf m4 libncurses-dev libwxgtk3.2-dev libwxgtk-webview3.2-dev libgl1-mesa-dev libglu1-mesa-dev libpng-dev libssh-dev unixodbc-dev xsltproc fop libxml2-utils libncurses-dev openjdk-17-jdk)

check_requirements() {
  # asdf plugin requirements
  for app in apt asdf dirmngr gpg curl gawk; do
    if ! command -v $app &> /dev/null; then
      echo "${app} could not be found"
      exit 1
    fi
  done
}

install_erlang_deps() {
  sudo apt install -y build-essential autoconf m4 libncurses-dev libwxgtk3.2-dev libwxgtk-webview3.2-dev libgl1-mesa-dev libglu1-mesa-dev libpng-dev libssh-dev unixodbc-dev xsltproc fop libxml2-utils libncurses-dev openjdk-17-jdk
}

install() {
  export KERL_BUILD_DOCS=yes
  asdf plugin-add erlang
  asdf install erlang 25.0.3
  asdf global erlang 25.0.3
}

check_requirements
install_erlang_deps
install
