#!/usr/bin/env bash

if command -v rclone &> /dev/null; then
  echo "✅ rclone already installed"
  exit 0
fi

source "$MYSCRIPTS/tools/utils.sh"

check_dependencies curl

install() {
  # Installing rclone with ignoring all errors -> || true
  curl https://rclone.org/install.sh | (sudo bash || true)
}

install
