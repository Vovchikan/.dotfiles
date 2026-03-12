#!/usr/bin/env bash

# Install onsly some extensions

set -Eeuo pipefail
source $MYSCRIPTS/utils.sh

install-nefrob.vscode-just() {
  # https://github.com/nefrob/vscode-just
  check_dependencies curl code jq
  LATEST_VERSION=$(curl -s https://api.github.com/repos/nefrob/vscode-just/releases/latest | jq -r '.tag_name')

  if code --list-extensions | grep -q "nefrob.vscode-just"; then
    INSTALLED_VERSION=$(code --list-extensions --show-versions | grep "nefrob.vscode-just" | cut -d@ -f2)

    if [ "$INSTALLED_VERSION" = "$LATEST_VERSION" ]; then
      echo "✅ nefrob.vscode-just already installed - ${LATEST_VERSION}"
      return 0
    fi
  fi

  curl -L "https://github.com/nefrob/vscode-just/releases/latest/download/vscode-just-syntax-${LATEST_VERSION}.vsix" \
    -o "$HOME/.vscode/extensions/vscode-just-syntax-${LATEST_VERSION}.vsix"

  code --install-extension "$HOME/.vscode/extensions/vscode-just-syntax-0.10.0.vsix"
}

install-nefrob.vscode-just