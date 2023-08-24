#!/usr/bin/env bash

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
DPATH="$script_dir/.." # scripts -> .dotfiles

set -Eeuo pipefail

function main() {

  software

  echo
  echo "+---------------------------------+"
  echo "|       Download submodules       |"
  echo "+---------------------------------+"
  echo
  git submodule update --recursive --init

  echo
  read -r -p "Install neovim? [y/N] " response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
  then
    neovim
  fi

  echo
  read -r -p "Install langs? [y/N] " response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
  then
    langs
  fi

  $script_dir/configs.sh

  echo
  echo "+---------------------------------+"
  echo "|   Download tmux plug manager    |"
  echo "|       and all tmux plugins      |"
  echo "+---------------------------------+"
  echo
  if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && \
      ~/.tmux/plugins/tpm/bin/install_plugins
  fi
}

function software() {

  if [ -f "~/.bash_profile" ]; then
    mv -v ~/.bash_profile ~/.bash_profile.backup
  fi
  cp -v $DPATH/templates/bash_profile.template ~/.bash_profile

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

# brew bash-git-prompt
if [ -f "$(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh" ]; then
  __GIT_PROMPT_DIR=$(brew --prefix)/opt/bash-git-prompt/share
  GIT_PROMPT_ONLY_IN_REPO=1
  source "$(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh"
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
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.12.0
  echo -e "\n. \"$HOME/.asdf/asdf.sh\"" >> ~/.bash_profile
  echo -e "\n. \"$HOME/.asdf/completions/asdf.bash\"" >> ~/.bash_profile

  echo
  echo "+---------------------------------+"
  echo "|        Installing rclone        |"
  echo "+---------------------------------+"
  echo
  # Installing rclone with ignoring all errors -> || true
  curl https://rclone.org/install.sh | (sudo bash || true)

  echo
  echo "+---------------------------------+"
  echo "|        Installing gitk          |"
  echo "+---------------------------------+"
  echo
  sudo apt install gitk

}

function neovim () {

  echo
  echo "+---------------------------------+"
  echo "|        Installing NeoVim        |"
  echo "+---------------------------------+"
  echo
  brew install neovim

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


  echo
  echo "+---------------------------------+"
  echo "|        Installing Elixir        |"
  echo "+---------------------------------+"
  echo
  sudo apt install -y unzip
  asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git
  asdf install elixir 1.14.1-otp-25
  asdf global elixir 1.14.1-otp-25

  # This need for Phoenix framework
  echo
  echo "+---------------------------------+"
  echo "|      Installing inotify-tools   |"
  echo "+---------------------------------+"
  echo
  sudo apt install inotify-tools

}

main
