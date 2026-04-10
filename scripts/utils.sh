#!/usr/bin/env bash

apt_update() {
  UPDATE_CACHE="/tmp/apt_updates_cache"
  CURRENT_TIME=$(date +%s)

  if [ -f "$UPDATE_CACHE" ] && [ $(($CURRENT_TIME - $(stat -c %Y "$UPDATE_CACHE"))) -lt 3600 ]; then
    UPDATES=$(cat "$UPDATE_CACHE")
  else
    echo "Executing (sudo apt update)..."
    sudo apt update -o Acquire::http::Timeout=5 -o Acquire::ftp::Timeout=5 > /dev/null 2>&1
    UPDATES=$(apt list --upgradable 2>/dev/null | grep -v "Listing...")
    echo "$UPDATES" > "$UPDATE_CACHE"
  fi

  if [ -z "$UPDATES" ]; then
    echo "No updates"
  else
    echo "$UPDATES"
    echo
    read -r -p "Execute apt upgrade? [y/N] " response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
      sudo apt upgrade -y
      rm -f "$UPDATE_CACHE"
    fi
  fi
}

# create copy of file in the same directory
# copy will have the same name with "~N~" at the end
# where N - is number of copy
backup_file() {
  cp -f --backup=numbered "$1" "$1"
}

# change default home directories to English
rename_dirs() {
  backup_file ~/.config/user-dirs.dirs
  backup_file ~/.config/user-dirs.locale
  LC_ALL=C.UTF-8 xdg-user-dirs-update --force
}

# Get key or create new if not exists
# the result will be in GPG_KEY_ID
get-gpg-lazy() {
  if [ $# -lt 2 ]; then
    echo "Ошибка: требуется указать имя и email"
    echo "Использование: get-gpg-lazy <имя> <email>"
    return 1
  fi

  local NAME="$1"
  local EMAIL="$2"
  local USER_STRING="$NAME <$EMAIL>"

  echo "Проверка наличия GPG-ключа для $USER_STRING..."

  # Поиск ключа по email
  GPG_KEY_ID=$(gpg --list-secret-keys --keyid-format LONG 2>/dev/null | grep -A1 "sec" | tail -1 | awk '{print $1}' | cut -d'/' -f2 || true)

  # Дополнительная проверка, что ключ принадлежит указанному email
  if [ -n "$GPG_KEY_ID" ]; then
    KEY_EMAIL=$(gpg --list-secret-keys --keyid-format LONG "$GPG_KEY_ID" 2>/dev/null | grep -A1 "uid" | tail -1 | sed -n 's/.*<\(.*\)>.*/\1/p')

    if [ "$KEY_EMAIL" != "$EMAIL" ]; then
      echo "Найден ключ с другим email: $KEY_EMAIL"
      GPG_KEY_ID=""
    fi
  fi

  if [ -z "$GPG_KEY_ID" ]; then
    echo "Создание нового GPG-ключа для $USER_STRING..."

    gpg --batch --passphrase '' \
      --quick-generate-key "$USER_STRING" default default never
    # Описание параметров
    # default        тип ключа (rsa3072)
    # default        тип subkey
    # never          срок действия

    # Повторная попытка получения ID после создания
    GPG_KEY_ID=$(gpg --list-secret-keys --keyid-format LONG 2>/dev/null | grep -A1 "sec" | tail -1 | awk '{print $1}' | cut -d'/' -f2)

    if [ -z "$GPG_KEY_ID" ]; then
      echo "Не удалось получить ID GPG-ключа. Проверьте процесс генерации."
      return 1
    fi

    echo "GPG-ключ успешно создан с ID: $GPG_KEY_ID"
    return 0
  else
    echo "Найден существующий GPG-ключ для $USER_STRING с ID: $GPG_KEY_ID"
    return 0
  fi
}

# Usage: check_dependencies "gpg" "curl" "pass" "pkg:gnupg" "pkg:libstdc++6"
check_dependencies() {
  local missing=()
  local script_name=$(basename "$0")
  local cmd_deps=()
  local pkg_deps=()

  for dep in "$@"; do
    if [[ "$dep" == pkg:* ]]; then
      pkg_deps+=("${dep#pkg:}")
    else
      # Это команда
      cmd_deps+=("$dep")
    fi
  done

  for app in "${cmd_deps[@]}"; do
    if ! command -v "$app" &> /dev/null; then
      missing+=("$app (command)")
    fi
  done

  for pkg in "${pkg_deps[@]}"; do
    if ! dpkg -s "$pkg" &> /dev/null; then
      missing+=("$pkg (package)")
    fi
  done

  if [ ${#missing[@]} -ne 0 ]; then
    echo "❌ Script '$script_name' is missing dependencies:"
    printf '  - %s\n' "${missing[@]}"
    echo
    echo "Please install missing dependencies and try again."
    exit 1
  fi
}

# Usage: check_ubuntu_version "24.04" "25.10"
check_ubuntu_version() {
  local allowed_versions=("$@")

  [ -f /etc/os-release ] || return 1
  . /etc/os-release

  [[ "$ID" == "ubuntu" || "$ID_LIKE" == *"ubuntu"* ]] || return 1

  for version in "${allowed_versions[@]}"; do
    [[ "$VERSION_ID" == "$version" ]] && return 0
  done

  return 1
}