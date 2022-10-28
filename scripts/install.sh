#!/usr/bin/env bash

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
DPATH="$script_dir/.." # install -> scripts -> .dotfiles

set -Eeuo pipefail

function main() {

  software 

  langs

  # $DPATH/scripts/linkconfigs.sh

}

function software() {

  if [ -f "~/.bash_profile" ]; then
    mv -v ~/.bash_profile /tmp/bash_profile.backup
  fi
  mv -v $DPATH/templates/bash_profile.template ~/.bash_profile

  echo
  echo "+---------------------------------+"
  echo "|        Installing brew-deps     |"
  echo "|            WITH SUDO            |"
  echo "|        procps curl file git     |"
  echo "|          build-essential        |"
  echo "+---------------------------------+"
  echo
  sudo apt-get install -y build-essential procps curl file git

  echo
  echo "+---------------------------------+"
  echo "|        Installing brew          |"
  echo "+---------------------------------+"
  echo
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Run these three commands in your terminal to add Homebrew to your PATH:
  test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
  test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  test -r ~/.bash_profile && echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.bash_profile

  echo
  echo "+---------------------------------+"
  echo "|  Configure brew completion      |"
  echo "+---------------------------------+"
  echo
tee -a ~/.bash_profile << EOF

# ---------------------------------------------------------------- #

# brew bash completion
if type brew &>/dev/null
then
  HOMEBREW_PREFIX="\$(brew --prefix)"
  if [[ -r "\${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]
  then
    source "\${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
  else
    for COMPLETION in "\${HOMEBREW_PREFIX}/etc/bash_completion.d/"*
    do
      [[ -r "\${COMPLETION}" ]] && source "\${COMPLETION}"
    done
  fi
fi

# ---------------------------------------------------------------- #

EOF

  echo
  echo "+---------------------------------+"
  echo "|    Installing brew bundle       |"
  echo "+---------------------------------+"
  echo
  brew bundle install --file $DPATH/Brewfile

  echo
  echo "+---------------------------------+"
  echo "|        Installing asdf-deps     |"
  echo "|        coureutils               |"
  echo "+---------------------------------+"
  echo
  brew install coreutils

  echo
  echo "+-------------------------------+"
  echo "|        Installing asdf        |"
  echo "+-------------------------------+"
  echo
  brew install asdf
  echo -e "\n. $(brew --prefix asdf)/libexec/asdf.sh" >> ~/.bash_profile

  echo
  echo "+---------------------------------+"
  echo "|        Installing NeoVim        |"
  echo "+---------------------------------+"
  echo
  brew install neovim

  echo
  echo "+---------------------------------+"
  echo "|        Installing kitty         |"
  echo "+---------------------------------+"
  echo
  curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

  # Create a symbolic link to add kitty to PATH (assuming ~/.local/bin is in
  # your system-wide PATH)
  if [ ! -d "~/.local/bin" ]; then
    mkdir ~/.local/bin
  fi
  ln -s ~/.local/kitty.app/bin/kitty ~/.local/bin/

  # Place the kitty.desktop file somewhere it can be found by the OS
  cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
  # If you want to open text files and images in kitty via your file manager also add the kitty-open.desktop file
  cp ~/.local/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/
  # Update the paths to the kitty and its icon in the kitty.desktop file(s)
  sed -i "s|Icon=kitty|Icon=/home/$USER/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
  sed -i "s|Exec=kitty|Exec=/home/$USER/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop


}

function langs () {

  echo
  echo "+---------------------------------+"
  echo "|        Installing NodeJS        |"
  echo "+---------------------------------+"
  echo
  brew install gpg tar
  asdf plugin-add nodejs
  asdf install nodejs 16.13.0
  asdf global nodejs 16.13.0

}

main
