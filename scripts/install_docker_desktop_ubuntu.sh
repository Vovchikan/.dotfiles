#!/usr/bin/env bash

# https://docs.docker.com/desktop/install/ubuntu/

check_deps() {
  if ! command -v apt &> /dev/null; then
    echo "apt could not be found"
    exit 1
  fi
}


install_deps() {
  sudo apt install -y gnome-terminal
}

# Set up Docker's package repository
#
# Step 1 only
# https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
setup_docker_rep() {
  # Add Docker's official GPG key:
  sudo apt-get update
  sudo apt-get install ca-certificates curl gnupg
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg

  # Add the repository to Apt sources:
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
}

check_deps

install_deps
setup_docker_rep

echo "
  Download latest docker deb package, see

  https://docs.docker.com/desktop/install/ubuntu/

  After download do:
  sudo apt update
  sudo apt install ./docker-desktop-<version>-<arch>.deb
"

