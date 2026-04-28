#!/usr/bin/env bash

TAR_NAME="backup_home_$(date +%F).tar.gz"

# -C ~ - переход в домашнюю директории перед созданием бэкапа
tar -cvpzf $TAR_NAME -C ~ \
  --exclude=".docker" \
  --exclude="Downloads" \
  --exclude="Videos" \
  --exclude="$TAR_NAME" \
  --exclude="backups" \
  --exclude="snap" \
  --exclude=".cache" \
  .
# Проверка путей в архиве
# tar -tzvf backup.tar.gz

# Извлечение файла из бэкапа
# tar -xzvf backup.tar.gz -C ~ ".bashrc"

# Извлечение файла в другое место
# mkdir -p ~/backups; tar -xzvf backup.tar.gz -C ~/backups ".bashrc"

# Извлечение папок (Слеш важен для папок!)
# tar -xzvf backup.tar.gz -C ~ "Documents/"
