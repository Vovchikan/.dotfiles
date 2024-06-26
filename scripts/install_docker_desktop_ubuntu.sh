#!/usr/bin/env bash

# https://docs.docker.com/desktop/install/ubuntu/

check_deps() {
  for app in apt curl; do
    if ! command -v $app &> /dev/null; then
      echo "${app} could not be found"
      exit 1
    fi
  done

  if command -v docker &> /dev/null; then
    echo "docker already installed"
    exit 0
  fi
}

# Set up Docker's package repository
#
# Step 1 only
# https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
setup_docker_rep() {
  # Add Docker's official GPG key:
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

setup_docker_rep

echo "
  Download latest docker deb package, see

  https://docs.docker.com/desktop/install/ubuntu/

  After download do:
  sudo apt update
  sudo apt install ./docker-desktop-<version>-<arch>.deb
"

# (ЕСЛИ ОБРАЗЫ НЕ СКАЧИВАЮТСЯ) После установки Docker Desktop, надо прописать зеркала, откуда будут скачиваться образы
#
# Открыть вкладку в Settings -> Docker Engine и добавить следующее
# "registry-mirrors": ["https://daocloud.io", "https://c.163.com/", "https://registry.docker-cn.com"]
#
# Если будет плохо работать, то поменять порядок на
# ["https://mirror.gcr.io", "https://daocloud.io", "https://c.163.com/", "https://registry.docker-cn.com"]