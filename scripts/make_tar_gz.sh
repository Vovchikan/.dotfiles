#!/usr/bin/env bash

DIR="$HOME/.dotfiles"
TAR_FILE="/tmp/dotfiles.tar.gz"

tar -cvzf $TAR_FILE $DIR

echo "$TAR_FILE"
