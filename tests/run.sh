#!/usr/bin/env bash

set -Eeuo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd -P)"
SANDBOX=""
EXIT_CODE=0

usage() {
  echo "Usage: $0 [--live | --sandbox]"
  exit 1
}

setup_sandbox() {
  SANDBOX=$(mktemp -d "/tmp/dotfiles-sandbox-XXXXXX")
  export HOME="$SANDBOX/home"
  mkdir -p "$HOME"
  mkdir -p "$HOME/.config"
  mkdir -p "$HOME/.local/share/konsole"

  cat > "$HOME/.bashrc" <<'BASHRC'
if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi
BASHRC

  # Pre-set hide alias so mc/link.sh doesn't fail
  git config --global alias.hide 'update-index --skip-worktree'
  git config --global alias.unhide 'update-index --no-skip-worktree'

  echo "=== Sandbox: $SANDBOX ==="
  cd "$DOTFILES_DIR"

  echo "--- Git config ---"
  ./configure/git.sh 2>&1 | sed 's/^/  /'

  echo "--- Link configurations ---"
  just link-configs 2>&1 | sed 's/^/  /'

  echo "--- Setup env ---"
  just setup-env 2>&1 | sed 's/^/  /'

  echo "--- Insert aliases ---"
  just insert-aliases 2>&1 | sed 's/^/  /'

  echo
}

cleanup_sandbox() {
  if [ -n "$SANDBOX" ] && [ -d "$SANDBOX" ]; then
    rm -rf "$SANDBOX"
    echo "Sandbox cleaned up"
  fi
}

run_tests() {
  for suite in "$DOTFILES_DIR/tests"/test_*.sh; do
    [ -f "$suite" ] || continue
    echo "=== $(basename "$suite" .sh | sed 's/test_//') ==="
    cd "$DOTFILES_DIR"
    bash "$suite" || ((EXIT_CODE++))
    echo
  done
}

trap cleanup_sandbox EXIT

case "${1:-}" in
  --live)    MODE="live" ;;
  --sandbox) MODE="sandbox"; setup_sandbox ;;
  *)         usage ;;
esac

export DOTFILES_DIR

echo "Running tests ($MODE mode)..."
echo
run_tests

[ "$EXIT_CODE" -eq 0 ] && echo "All suites passed!" || echo "Some suites failed."
exit "$EXIT_CODE"
