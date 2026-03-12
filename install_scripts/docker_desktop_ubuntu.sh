#!/usr/bin/env bash

# https://docs.docker.com/desktop/install/ubuntu/

if command -v docker &> /dev/null; then
  echo "✅ docker already installed"
  exit 0
fi

echo
read -r -p "Install docker for Ubuntu? [y/N] " response
if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
  exit 0
fi

deps=(
  "apt"
  "gpg"
  "curl"
  "pass"
  "gnome-terminal"
  "pkg:gnupg"
  "pkg:libstdc++6"
  "pkg:ca-certificates"
)

set -Eeuo pipefail

NAME="Vladimir"
EMAIL="vovchikan@gmail.com"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 1
source "$SCRIPT_DIR/../scripts/utils.sh"

check_dependencies "${deps[@]}"

# https://docs.docker.com/desktop/setup/sign-in/
# https://www.passwordstore.org/
setup_docker_pass() {
  if [ -d "$HOME/.password-store" ] && [ -f "$HOME/.password-store/.gpg-id" ]; then
    echo "Хранилище 'pass' уже инициализировано. Выход."
    return 0
  fi

  # the result will be in GPG_KEY_ID
  get-gpg-lazy "$NAME" "$EMAIL"

  # write gpg-key to ~/.password-store/.gpg-id
  pass init "$GPG_KEY_ID"

  if [ $? -eq 0 ]; then
    echo "✅ Настройка успешно завершена. Теперь вы можете войти в Docker Desktop."
    echo "Примечание: При использовании учётных данных может появиться запрос на пароль от GPG-ключа."
  else
    echo "❌ Ошибка при инициализации 'pass'."
    return 1
  fi
}

# Set up Docker's package repository
#
# Step 1 only
# https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
setup_docker_rep() {
  # Add Docker's official GPG key:
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  # Add the repository to Apt sources:
  sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF
}

check_deps
setup_docker_pass
setup_docker_rep
sudo apt update

# Step 2 only
echo "
  Download latest docker deb package, see

  https://docs.docker.com/desktop/install/ubuntu/

  After download do:
  sudo apt install ./docker-desktop-<version>-<arch>.deb
"

# (ЕСЛИ ОБРАЗЫ НЕ СКАЧИВАЮТСЯ) После установки Docker Desktop, надо прописать зеркала, откуда будут скачиваться образы
#
# Открыть вкладку в Settings -> Docker Engine и добавить следующее
# "registry-mirrors": ["https://daocloud.io", "https://c.163.com/", "https://registry.docker-cn.com"]
#
# Если будет плохо работать, то поменять порядок на
# ["https://mirror.gcr.io", "https://daocloud.io", "https://c.163.com/", "https://registry.docker-cn.com"]