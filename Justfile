# https://just.systems/man/en/quick-start.html

# List just-commands
default:
  just --list

# Install apps and nesseccery libraries
install:
  ./install_scripts/main.sh

# Install cargo and cargo apps
install-cargo:
  ./install_scripts/cargo.sh

# Install some extensions for vs-code
install-vscode-ext:
  ./install_scripts/vscode.sh

# Configure apps
configure:
  ./configure_scripts/main.sh
  ./vim/link.sh
  ./tmux/link.sh

# (Not tested!) Change default home directories to English
rename-home-dirs:
  #!/usr/bin/env bash
  . ./scripts/utils.sh
  rename_dirs
# Create python venv
venv:
  make venv

# Update bash aliases in current shell from "bash_alises" files
update-aliases: setup-env insert-aliases
  #!/usr/bin/env bash
  . ~/.bashrc

# Create ~/.my_scripts.conf
setup-env:
  config/setup_env.py

# Add bash aliases
insert-aliases:
  config/insert_aliases.py -s scripts/bash_aliases
  #!/usr/bin/env bash
  if [ -f work-scripts/funbox/bash_aliases ]; then \
    config/insert_aliases.py -s work-scripts/funbox/bash_aliases; \
  fi