#!/usr/bin/env bash

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
DPATH="$script_dir/.." # scripts -> .dotfiles

set -Eeuo pipefail

function main() {

  software 

  echo
  read -r -p "Install langs? [y/N] " response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
  then
    langs
  fi

  $script_dir/configs.sh
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
  if [ ! -d "~/.local/share/applications/" ]; then
    mkdir ~/.local/share/applications/
  fi
  cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
  # If you want to open text files and images in kitty via your file manager also add the kitty-open.desktop file
  cp ~/.local/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/
  # Update the paths to the kitty and its icon in the kitty.desktop file(s)
  sed -i "s|Icon=kitty|Icon=/home/$USER/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
  sed -i "s|Exec=kitty|Exec=/home/$USER/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop


  echo
  echo "+---------------------------------+"
  echo "|        Installing rclone        |"
  echo "+---------------------------------+"
  echo
  curl https://rclone.org/install.sh | sudo bash

}

function langs () {

  echo
  echo "+---------------------------------+"
  echo "|        Installing NodeJS        |"
  echo "+---------------------------------+"
  echo
  asdf plugin-add nodejs
  asdf install nodejs 16.13.0
  asdf global nodejs 16.13.0


  echo
  echo "+---------------------------------+"
  echo "|        Installing Erlang        |"
  echo "+---------------------------------+"
  echo
  sudo apt install -y build-essential autoconf m4 libncurses5-dev libwxgtk3.0-gtk3-dev libwxgtk-webview3.0-gtk3-dev libgl1-mesa-dev libglu1-mesa-dev libpng-dev libssh-dev unixodbc-dev xsltproc fop libxml2-utils libncurses-dev openjdk-11-jdk
  asdf plugin-add erlang
  asdf install erlang 25.0.4
  asdf global erlang 25.0.4

}

main
