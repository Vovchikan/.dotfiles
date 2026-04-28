#!/usr/bin/env bash

# Install VS Code extensions

set -Eeuo pipefail
source $MYSCRIPTS/tools/utils.sh

# Install VS Code extension from GitHub releases
# Usage: install_vscode_ext_from_github <repo>
#   repo - GitHub "owner/repo"
#
# Requirements:
#   - repo must have package.json in root with "publisher" and "name" fields
#   - latest release must contain a .vsix asset named "{name}-{version}.vsix"
install_vscode_ext_from_github() {
  local REPO="$1"

  check_dependencies curl code jq

  local PKG_JSON
  PKG_JSON=$(curl -s "https://raw.githubusercontent.com/${REPO}/master/package.json")
  if [ -z "$PKG_JSON" ] || ! echo "$PKG_JSON" | jq -e '.publisher' > /dev/null 2>&1; then
    PKG_JSON=$(curl -s "https://raw.githubusercontent.com/${REPO}/main/package.json")
  fi

  local PUBLISHER NAME
  PUBLISHER=$(echo "$PKG_JSON" | jq -r '.publisher')
  NAME=$(echo "$PKG_JSON" | jq -r '.name')
  local EXT_ID="${PUBLISHER}.${NAME}"

  local LATEST_VERSION
  LATEST_VERSION=$(curl -s "https://api.github.com/repos/${REPO}/releases/latest" | jq -r '.tag_name')

  if [ -z "$LATEST_VERSION" ] || [ "$LATEST_VERSION" = "null" ]; then
    echo "❌ Failed to fetch latest version for ${REPO}"
    return 1
  fi

  if code --list-extensions | grep -q "${EXT_ID}"; then
    local INSTALLED_VERSION
    INSTALLED_VERSION=$(code --list-extensions --show-versions | grep "${EXT_ID}" | cut -d@ -f2)

    if [ "$INSTALLED_VERSION" = "$LATEST_VERSION" ]; then
      echo "✅ ${EXT_ID} already installed - ${LATEST_VERSION}"
      return 0
    fi
  fi

  local VSIX_NAME="${NAME}-${LATEST_VERSION}.vsix"
  local VSIX_URL="https://github.com/${REPO}/releases/latest/download/${VSIX_NAME}"
  local TMP_DIR
  TMP_DIR=$(mktemp -d)

  curl -L "$VSIX_URL" -o "${TMP_DIR}/${VSIX_NAME}"
  code --install-extension "${TMP_DIR}/${VSIX_NAME}"
  rm -rf "$TMP_DIR"
}

install-nefrob.vscode-just() {
  install_vscode_ext_from_github "nefrob/vscode-just"
}

install-nefrob.vscode-just
