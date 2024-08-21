#!/usr/bin/env bash

# https://docs.docker.com/desktop/install/ubuntu/

set -Eeuo pipefail

check_deps() {
  for app in apt curl gnome-terminal; do
    if ! command -v $app &> /dev/null; then
      echo "${app} could not be found"
      exit 1
    fi
  done

  for app in ca-certificates gnupg; do
    if ! dpkg -s $app &> /dev/null; then
      echo "${app} package not installed"
      exit 1
    fi
  done

  if command -v docker &> /dev/null; then
    echo "docker already installed"
    exit 0
  fi
}

# https://docs.docker.com/desktop/setup/sign-in/
# https://www.passwordstore.org/
setup_docker_pass() {
  if ! command -v pass &> /dev/null; then
    echo "pass could not be found"
    exit 0
  fi

  # 1. Проверка, инициализировано ли уже хранилище pass
  if [ -d "$HOME/.password-store" ] && [ -f "$HOME/.password-store/.gpg-id" ]; then
    echo "Хранилище 'pass' уже инициализировано. Выход."
    return 0
  fi

  # 2. Проверка наличия GPG-ключа
  echo "Проверка наличия GPG-ключа..."
  GPG_KEY_ID=$(gpg --list-secret-keys --keyid-format LONG 2>/dev/null | grep -A1 "sec" | tail -1 | awk '{print $1}' | cut -d'/' -f2)

  if [ -z "$GPG_KEY_ID" ]; then
    echo "GPG-ключ не найден. Будет создан новый."
    # 3. Генерация нового GPG-ключа (интерактивно)
    # Используйте --batch для автоматизации, но здесь для примера — интерактивный режим
    if ! command -v gpg &> /dev/null; then
      echo "Ошибка: 'gpg' не установлен. Установите пакет gnupg."
      return 1
    fi
    gpg --full-generate-key
    # Повторная попытка получения ID после создания
    GPG_KEY_ID=$(gpg --list-secret-keys --keyid-format LONG 2>/dev/null | grep -A1 "sec" | tail -1 | awk '{print $1}' | cut -d'/' -f2)
    if [ -z "$GPG_KEY_ID" ]; then
      echo "Не удалось получить ID GPG-ключа. Проверьте процесс генерации."
      return 1
    fi
  else
    echo "Найден существующий GPG-ключ с ID: $GPG_KEY_ID"
  fi

  # 4. Инициализация pass с использованием GPG ID
  echo "Инициализация хранилища 'pass' с ключом $GPG_KEY_ID..."
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