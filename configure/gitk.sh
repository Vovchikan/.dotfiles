#!/usr/bin/env bash

pushd /tmp
git clone https://github.com/dracula/gitk.git
#git clone https://github.com/claudsonm/gitk-material-dark-theme.git gitk
mkdir -p ~/.config/git
cp --backup=numbered gitk/gitk ~/.config/git
rm -rf /tmp/gitk
popd