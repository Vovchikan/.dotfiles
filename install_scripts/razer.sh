#!/usr/bin/env bash

set -Eeuo pipefail
source "$MYSCRIPTS/utils.sh"

supported_versions=(
  "24.04"
  "24.10"
  "25.04"
  "25.10"
)
if ! check_ubuntu_version "${supported_versions[@]}"; then
  echo "✗ Система не поддерживается"
  exit 0
fi

[ -f /etc/os-release ] || exit 1
. /etc/os-release

# Razer Daemon - https://openrazer.github.io/#download
sudo apt install -y openrazer-meta
# Razer gui https://github.com/z3ntu/RazerGenie?tab=readme-ov-file
# Install instructions https://software.opensuse.org//download.html?project=hardware%3Arazer&package=razergenie
echo 'deb http://download.opensuse.org/repositories/hardware:/razer/xUbuntu_$VERSION_ID/ /' | sudo tee /etc/apt/sources.list.d/hardware:razer.list
curl -fsSL https://download.opensuse.org/repositories/hardware:razer/xUbuntu_$VERSION_ID/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/hardware_razer.gpg > /dev/null
sudo apt update
sudo apt install razergenie