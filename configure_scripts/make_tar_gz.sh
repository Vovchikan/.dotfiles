#!/usr/bin/env bash

DIR=".dotfiles"
TAR_FILE="/tmp/dotf.tar.gz"
PWD=$(pwd)

cd ~
tar -cvzf $TAR_FILE $DIR
cd $PWD

echo "$TAR_FILE"
