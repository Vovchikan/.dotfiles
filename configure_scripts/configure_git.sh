#!/usr/bin/env bash

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
git config --global --remove-section alias
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
  | sed -E \"s/^([^ ]+)/$(tput setaf 3)&$(tput sgr0)/; s/([0-9a-f]{7,10})/$(tput setaf 2)&$(tput sgr0)/; s/([0-9]{4}-[0-9]{2}-[0-9]{2})/$(tput setaf 4)&$(tput sgr0)/\""


git config --list --global