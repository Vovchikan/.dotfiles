#!/usr/bin/env bash

create-gpg-if-not-exists() {
  if [ $# -lt 2 ]; then
    echo "Ошибка: требуется указать имя и email"
    echo "Использование: create-gpg-if-not-exists <имя> <email>"
    return 1
  fi

  local NAME="$1"
  local EMAIL="$2"
  local USER_STRING="$NAME <$EMAIL>"

  echo "Проверка наличия GPG-ключа для $USER_STRING..."

  # Поиск ключа по email
  GPG_KEY_ID=$(gpg --list-secret-keys --keyid-format LONG 2>/dev/null | grep -A1 "sec" | tail -1 | awk '{print $1}' | cut -d'/' -f2)

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

    echo "GPG-ключ успешно создан с ID:"
    echo "$GPG_KEY_ID"
    return 0
  else
    echo "Найден существующий GPG-ключ для $USER_STRING с ID:"
    echo "$GPG_KEY_ID"
    return 0
  fi
}
