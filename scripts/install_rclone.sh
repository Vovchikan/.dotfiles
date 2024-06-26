#!/usr/bin/env bash

check_requirements() {
  if ! command -v curl &> /dev/null; then
    echo "curl could not be found"
    exit 1
  fi

  if command -v rclone &> /dev/null; then
    echo "rclone already installed"
    exit 0
  fi
}

install() {
  # Installing rclone with ignoring all errors -> || true
  curl https://rclone.org/install.sh | (sudo bash || true)
}

check_requirements
install
