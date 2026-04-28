#!/usr/bin/env bash

set -Eeuo pipefail

source $MYSCRIPTS/tools/utils.sh

# Show all files of last release (for testing)
# curl -s https://api.github.com/repos/Umio-Yasuno/amdgpu_top/releases/latest | jq -r '.assets[].name'

install-amdgpu_top() {
  # https://github.com/Umio-Yasuno/amdgpu_top
  check_dependencies curl code jq
  LATEST_VERSION=$(curl -s https://api.github.com/repos/Umio-Yasuno/amdgpu_top/releases/latest | jq -r '.tag_name[1:]')

  echo $LATEST_VERSION

  curl -L "https://github.com/Umio-Yasuno/amdgpu_top/releases/latest/download/amdgpu-top_${LATEST_VERSION}-1_amd64.deb" \
    -o "/tmp/amdgpu-top_${LATEST_VERSION}_amd64.deb"

  sudo apt install "/tmp/amdgpu-top_${LATEST_VERSION}-1_amd64.deb"
}

install-amdgpu_top