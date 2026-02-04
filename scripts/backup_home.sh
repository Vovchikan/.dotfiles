#!/usr/bin/env bash

# -C ~ - переход в домашнюю директории перед созданием бэкапа
tar -cvpzf backup.tar.gz -C ~ \
  --exclude=".docker" \
  --exclude="Downloads" \
  .
# Проверка путей в архиве
# tar -tzvf backup.tar.gz

# Извлечение файла из бэкапа
# tar -xzvf backup.tar.gz -C ~ ".bashrc"

# Извлечение файла в другое место
# mkdir -p ~/backups; tar -xzvf backup.tar.gz -C ~/backups ".bashrc"

# Извлечение папок (Слеш важен для папок!)
# tar -xzvf backup.tar.gz -C ~ "Documents/"