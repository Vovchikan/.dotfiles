#!/usr/bin/env bash

# Install VS Code extensions

set -Eeuo pipefail
source $MYSCRIPTS/tools/utils.sh

# Escape XML special characters for use in extension.vsixmanifest
xml_escape() {
  printf '%s' "$1" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'
}

# Return 0 if extension <id> is installed at exactly <version>
vscode_is_installed() {
  local EXT_ID="$1" VERSION="$2"
  if code --list-extensions | grep -q "${EXT_ID,,}"; then
    local INSTALLED
    INSTALLED=$(code --list-extensions --show-versions | grep "${EXT_ID,,}" | cut -d@ -f2)
    [ "$INSTALLED" = "$VERSION" ] && return 0
  fi
  return 1
}

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

# Install VS Code extension from source when the repo has no GitHub releases.
# Usage: install_vscode_ext_from_source <repo> [branch]
#   repo   - GitHub "owner/repo"
#   branch - optional branch name; defaults to "master", falls back to "main"
#
# Downloads the source tarball and builds a .vsix manually (zip + manifest),
# so node/npm are NOT required.
#
# Requirements:
#   - repo must have package.json in root with "publisher" and "name" fields
#   - pure JavaScript extension with no build step (no compile/prepublish
#     scripts, "main" must point to an existing .js file in the repository)
#   - otherwise a "Variant 2" (npm + vsce) stub message is printed
install_vscode_ext_from_source() {
  local REPO="$1"
  local BRANCH="${2:-}"
  local PKG_JSON

  check_dependencies curl code jq zip

  # Detect branch and fetch package.json (master -> main fallback)
  if [ -n "$BRANCH" ]; then
    PKG_JSON=$(curl -fsSL "https://raw.githubusercontent.com/${REPO}/${BRANCH}/package.json" 2>/dev/null) || PKG_JSON=""
  else
    PKG_JSON=$(curl -fsSL "https://raw.githubusercontent.com/${REPO}/master/package.json" 2>/dev/null) || PKG_JSON=""
    if [ -z "$PKG_JSON" ] || ! echo "$PKG_JSON" | jq -e '.publisher' > /dev/null 2>&1; then
      BRANCH="main"
      PKG_JSON=$(curl -fsSL "https://raw.githubusercontent.com/${REPO}/main/package.json" 2>/dev/null) || PKG_JSON=""
    else
      BRANCH="master"
    fi
  fi

  if [ -z "$PKG_JSON" ] || ! echo "$PKG_JSON" | jq -e '.publisher' > /dev/null 2>&1; then
    echo "❌ Failed to fetch package.json for ${REPO}"
    return 1
  fi

  local PUBLISHER NAME VERSION DISPLAY_NAME DESCRIPTION
  PUBLISHER=$(echo "$PKG_JSON" | jq -r '.publisher')
  NAME=$(echo "$PKG_JSON" | jq -r '.name')
  VERSION=$(echo "$PKG_JSON" | jq -r '.version // empty')
  DISPLAY_NAME=$(echo "$PKG_JSON" | jq -r '.displayName // empty')
  DESCRIPTION=$(echo "$PKG_JSON" | jq -r '.description // empty')
  local EXT_ID="${PUBLISHER}.${NAME}"

  if [ -z "$VERSION" ]; then
    echo "❌ ${EXT_ID}: version not found in package.json"
    return 1
  fi

  if vscode_is_installed "$EXT_ID" "$VERSION"; then
    echo "✅ ${EXT_ID} already installed - ${VERSION}"
    return 0
  fi

  local TMP_DIR
  TMP_DIR=$(mktemp -d)
  local TARBALL="${TMP_DIR}/source.tar.gz"

  echo "⬇️  Downloading ${REPO}@${BRANCH}..."
  if ! curl -fsSL "https://codeload.github.com/${REPO}/tar.gz/refs/heads/${BRANCH}" -o "$TARBALL"; then
    echo "❌ Failed to download source for ${REPO} (branch ${BRANCH})"
    rm -rf "$TMP_DIR"
    return 1
  fi

  tar -xzf "$TARBALL" -C "$TMP_DIR"

  local SRC_DIR
  SRC_DIR=$(find "$TMP_DIR" -mindepth 1 -maxdepth 1 -type d | head -1)
  if [ -z "$SRC_DIR" ]; then
    echo "❌ Source archive is empty for ${REPO}"
    rm -rf "$TMP_DIR"
    return 1
  fi

  # --- Check if the zip-based build (Variant 1) is applicable ---
  local MAIN_SCRIPT BUILD_SCRIPTS REASON=""
  MAIN_SCRIPT=$(echo "$PKG_JSON" | jq -r '.main // empty')
  BUILD_SCRIPTS=$(echo "$PKG_JSON" | jq -r '[.scripts["vscode:prepublish"], .scripts.compile, .scripts.build, .scripts["vscode:prebundle"]] | map(select(. != null)) | join(", ")' 2>/dev/null || true)

  if [ -n "$MAIN_SCRIPT" ]; then
    local MAIN_FILE="${MAIN_SCRIPT#./}"
    case "$MAIN_SCRIPT" in
      *.ts|*.tsx|*.mts|*.cts)
        REASON="entry point '${MAIN_SCRIPT}' is TypeScript and needs compilation"
        ;;
      *)
        if [ ! -f "${SRC_DIR}/${MAIN_FILE}" ] && [ ! -f "${SRC_DIR}/${MAIN_FILE}.js" ]; then
          REASON="entry point '${MAIN_SCRIPT}' is not present in the repository (needs compilation)"
        fi
        ;;
    esac
  fi
  if [ -n "$BUILD_SCRIPTS" ]; then
    REASON="${REASON:+${REASON}; }has a build step (npm scripts: ${BUILD_SCRIPTS})"
  fi

  if [ -n "$REASON" ]; then
    echo "❌ ${EXT_ID}: cannot be built from source with the zip-based method (Variant 1)."
    echo "   Reason: ${REASON}"
    echo
    echo "   Variant 2 (npm + vsce) is not implemented yet. To add support:"
    echo "     1. cd <source dir>"
    echo "     2. npm install --ignore-scripts"
    echo "     3. npm run compile   # or the build script reported above"
    echo "     4. npx @vscode/vsce package"
    echo "     5. code --install-extension <publisher>-<name>-<version>.vsix"
    echo "   Implement an install_vscode_ext_from_source_npm() function in install_scripts/vscode.sh."
    rm -rf "$TMP_DIR"
    return 1
  fi

  # --- Build .vsix manually ---
  echo "📦 Building .vsix for ${EXT_ID} (${VERSION}) from source..."
  local VSIX_DIR="${TMP_DIR}/vsix"
  mkdir -p "${VSIX_DIR}/extension"
  cp -r "${SRC_DIR}/." "${VSIX_DIR}/extension/"

  local DISPLAY_ESC DESCRIPTION_ESC
  DISPLAY_ESC=$(xml_escape "$DISPLAY_NAME")
  DESCRIPTION_ESC=$(xml_escape "$DESCRIPTION")

  {
    printf '<?xml version="1.0" encoding="utf-8"?>\n'
    printf '<PackageManifest Version="2.0.0" xmlns="http://schemas.microsoft.com/developer/vsx-schema/2011" xmlns:d="http://schemas.microsoft.com/developer/vsx-schema-design/2011">\n'
    printf '  <Metadata>\n'
    printf '    <Identity Language="en-US" Id="%s" Version="%s" Publisher="%s" />\n' "$NAME" "$VERSION" "$PUBLISHER"
    printf '    <DisplayName>%s</DisplayName>\n' "$DISPLAY_ESC"
    printf '    <Description xml:space="preserve">%s</Description>\n' "$DESCRIPTION_ESC"
    printf '    <GalleryFlags>Public</GalleryFlags>\n'
    printf '  </Metadata>\n'
    printf '  <Installation>\n'
    printf '    <InstallationTarget Id="Microsoft.VisualStudio.Code"/>\n'
    printf '  </Installation>\n'
    printf '  <Dependencies/>\n'
    printf '  <Assets>\n'
    printf '    <Asset Type="Microsoft.VisualStudio.Code.Manifest" Path="extension/package.json" Addressable="true" />\n'
    printf '  </Assets>\n'
    printf '</PackageManifest>\n'
  } > "${VSIX_DIR}/extension.vsixmanifest"

  {
    printf '<?xml version="1.0" encoding="utf-8"?>\n'
    printf '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">\n'
    printf '  <Default Extension=".js" ContentType="application/javascript"/>\n'
    printf '  <Default Extension=".json" ContentType="application/json"/>\n'
    printf '  <Default Extension=".png" ContentType="image/png"/>\n'
    printf '  <Default Extension=".md" ContentType="text/markdown"/>\n'
    printf '  <Default Extension=".txt" ContentType="text/plain"/>\n'
    printf '  <Default Extension=".vsixmanifest" ContentType="text/xml"/>\n'
    printf '  <Default Extension="*" ContentType="application/octet-stream"/>\n'
    printf '</Types>\n'
  } > "${VSIX_DIR}/[Content_Types].xml"

  local VSIX_PATH="${TMP_DIR}/${NAME}-${VERSION}.vsix"
  (cd "${VSIX_DIR}" && zip -qr "${VSIX_PATH}" .)

  local RESULT=0
  code --install-extension "${VSIX_PATH}" || RESULT=$?
  rm -rf "$TMP_DIR"
  return "$RESULT"
}

install_vscode_ext_from_github "nefrob/vscode-just"
install_vscode_ext_from_source "daviduuang/ini-for-vscode"
