#!/usr/bin/env bash

TAR_NAME="backup_home_$(date +%F).tar.zst"
LOG_NAME="backup_home_$(date +%F).log"
START=$(date +%s)

mkdir -p ~/backups

# -C ~ - переход в домашнюю директории перед созданием бэкапа
tar -cvf "$HOME/backups/$TAR_NAME" --use-compress-program='zstd -T0' -C ~ \
  --exclude="backup_home_*" \
  --exclude=".local/share/Steam" \
  --exclude=".local/share/TelegramDesktop" \
  --exclude=".docker" \
  --exclude=".ollama" \
  --exclude="Downloads" \
  --exclude="Videos" \
  --exclude="backups" \
  --exclude="snap" \
  --exclude=".cache" \
  --exclude="*.mkv" \
  --exclude="*.mp4" \
  --exclude="*.avi" \
  --exclude="*.mov" \
  --exclude="*.wmv" \
  --exclude="*.flv" \
  --exclude="*.webm" \
  --exclude="*.m4v" \
  --exclude="*.mpg" \
  --exclude="*.mpeg" \
  --exclude="*.m2ts" \
  --exclude="*.ts" \
  --exclude="*.vob" \
  --exclude="*.iso" \
  --exclude="*.3gp" \
  --exclude="*.ogv" \
  --exclude="*.divx" \
  --exclude="*.mts" \
  --exclude="*.rm" \
  --exclude="*.rmvb" \
  --exclude="*.f4v" \
  --exclude="*.asf" \
  --exclude="*[Ff]ilms" \
  --exclude="*[Dd]ropbox" \
  --totals . > "/tmp/$LOG_NAME"

END=$(date +%s)
echo "Backup: $HOME/backups/$TAR_NAME"
echo "Log:   /tmp/$LOG_NAME"
echo "Elapsed: $((END - START))s"
# Проверка путей в архиве
# tar -tavf backup.tar.zst

# Извлечение файла из бэкапа
# tar -xavf backup.tar.zst -C ~ ".bashrc"

# Извлечение файла в другое место
# mkdir -p ~/backups; tar -xavf backup.tar.zst -C ~/backups ".bashrc"

# Извлечение папок (Слеш важен для папок!)
# tar -xavf backup.tar.zst -C ~ "Documents/"
