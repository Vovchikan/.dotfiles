#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 1
source "$SCRIPT_DIR/../scripts/tools/utils.sh"

check_dependencies git

git config --global user.name "Vladimir Samorodov"
git config --global user.email vovchikan@gmail.com
git config --global core.editor vim
git config --global core.excludesfile "~/.gitignore"
git config --global pull.ff only

# Автоматом соединит комиты заплатки (fixup) при интерактивном перебазировании
git config --global rebase.autosquash true

# Сокращения в интерактивном перебазировании
git config --global rebase.abbreviatecommands true

# Aliases
git config --global alias.s 'status'
git config --global alias.lol 'log --oneline'
git config --global alias.lol3 'lol -3'
git config --global alias.lol5 'lol -5'
git config --global alias.pull 'pull --ff-only'
git config --global alias.fixup 'commit --amend --no-edit'
git config --global alias.taglog \
"!git for-each-ref --sort=committerdate \
  --format='%(refname:short)|%(objectname:short)|%(committerdate:short)|%(subject)' refs/tags \
  | column -t -s '|' \
  | if [ -t 1 ]; then \
      sed -E \"s/^([^ ]+)/$(tput setaf 3)&$(tput sgr0)/; s/([0-9a-f]{7,10})/$(tput setaf 2)&$(tput sgr0)/; s/([0-9]{4}-[0-9]{2}-[0-9]{2})/$(tput setaf 4)&$(tput sgr0)/\"; \
    else \
      cat; \
    fi"

## hide changes in indexed files (only for local use)
git config --global alias.hide 'update-index --skip-worktree'
git config --global alias.unhide 'update-index --no-skip-worktree'
git config --global alias.hidden '!git ls-files -v | grep "^S"'

## ignore changes in indexed files (only for local use)
git config --global alias.assume 'update-index --assume-unchanged'
git config --global alias.unassume 'update-index --no-assume-unchanged'
git config --global alias.assumed '!git ls-files -v | grep "^h"'

git config --list --global
