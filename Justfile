# https://just.systems/man/en/quick-start.html

# List just-commands
default:
  @just --list --unsorted --justfile {{justfile()}}

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
  ./configure/main.sh

# Configure apps
configure-git:
  ./configure/git.sh

# Create sym-links in ~/.config
link-configurations:
  - ./app_configs/vim/link.sh
  - ./app_configs/tmux/link.sh
  - ./app_configs/mc/link.sh
  - ./app_configs/konsole/link.sh

# Create python venv
venv:
  make venv

# Create ~/.my_scripts.conf
setup-env:
  helpers/setup_env.py

# Add bash aliases to .bashrc
insert-aliases:
  helpers/insert_aliases.py -s scripts/aliases/bash_aliases
  #!/usr/bin/env bash
  if [ -f work-scripts/funbox/bash_aliases ]; then \
    helpers/insert_aliases.py -s work-scripts/funbox/bash_aliases; \
  fi
  mkdir -p ~/.local/share/bash-completion/completions
  @just --completions bash > ~/.local/share/bash-completion/completions/just

# Change default home directories to English
rename-home-dirs:
  #!/usr/bin/env bash
  . ./scripts/tools/utils.sh
  rename_dirs

# Package, send and extract on remote machine
deploy user host:
  #!/usr/bin/env bash
  set -Eeuo pipefail
  USER="{{user}}"
  HOST="{{host}}"
  SSH_OPTS="-o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=/dev/null"
  git ls-files -c -o --exclude-standard | tar -czf /tmp/dotfiles.tar.gz -T -
  scp $SSH_OPTS /tmp/dotfiles.tar.gz "$USER@$HOST:/tmp/"
  ssh $SSH_OPTS "$USER@$HOST" \
    "mkdir -p ~/dotfiles && tar -xzf /tmp/dotfiles.tar.gz -C ~/dotfiles && rm /tmp/dotfiles.tar.gz"
  rm /tmp/dotfiles.tar.gz

# Run tests on host (read-only)
test:
  ./tests/run.sh --live

# Run tests in isolated sandbox
test-sandbox:
  ./tests/run.sh --sandbox

# Create test VM (headless)
test-vm-create:
  ./tests/vm/create.sh

# Create test VM with KDE desktop
test-vm-create-desktop:
  ./tests/vm/create.sh --desktop

# Destroy a test VM
test-vm-destroy name:
  ./tests/vm/destroy.sh {{name}}

# Destroy all test VMs
test-vm-destroy-all:
  ./tests/vm/destroy.sh --all

# Deploy and run tests on a VM (auto-detects IP)
test-vm user="testuser" vm="dotfiles-test":
  #!/usr/bin/env bash
  set -Eeuo pipefail
  VM="{{vm}}"
  USER="{{user}}"
  SSH_OPTS="-o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=/dev/null"
  IP=$(virsh domifaddr "$VM" 2>/dev/null | grep -oP '\d+\.\d+\.\d+\.\d+' | head -1) || true
  if [ -z "$IP" ]; then
    for i in $(seq 1 30); do
      IP=$(virsh domifaddr "$VM" 2>/dev/null | grep -oP '\d+\.\d+\.\d+\.\d+' | head -1) || true
      [ -n "$IP" ] && break
      sleep 2
    done
  fi
  [ -z "$IP" ] && echo "VM '$VM' not reachable" && exit 1
  echo "VM IP: $IP"
  echo "Waiting for SSH..."
  for i in $(seq 1 15); do
    ssh $SSH_OPTS "$USER@$IP" exit 2>/dev/null && break
    sleep 2
  done
  if ! ssh $SSH_OPTS "$USER@$IP" exit 2>/dev/null; then
    echo "SSH not available after 30 seconds"; exit 1
  fi
  echo "Waiting for cloud-init..."
  ssh $SSH_OPTS "$USER@$IP" "cloud-init status --wait" </dev/null || true
  git ls-files -c -o --exclude-standard | tar -czf /tmp/dotfiles.tar.gz -T -
  scp $SSH_OPTS /tmp/dotfiles.tar.gz "$USER@$IP:/tmp/"
  ssh $SSH_OPTS "$USER@$IP" \
    "mkdir -p ~/dotfiles ~/.config ~/.local/share/konsole \
     && tar -xzf /tmp/dotfiles.tar.gz -C ~/dotfiles \
     && rm /tmp/dotfiles.tar.gz \
     && cd ~/dotfiles \
     && just configure-git \
     && just link-configurations \
     && just setup-env \
     && just insert-aliases \
     && ./tests/run.sh --live"
  rm /tmp/dotfiles.tar.gz

# Create headless VM -> deploy+test -> destroy
test-vm-fullcycle:
  #!/usr/bin/env bash
  set -Eeuo pipefail
  ./tests/vm/create.sh
  just test-vm
  ./tests/vm/destroy.sh dotfiles-test

# Deploy and test on desktop VM
test-vm-desktop:
  #!/usr/bin/env bash
  set -Eeuo pipefail
  SNAPSHOT_SCRIPT="./tests/vm/snapshot.sh"
  if "$SNAPSHOT_SCRIPT" has dotfiles-test-desktop; then
    echo "Reverting to clean snapshot..."
    "$SNAPSHOT_SCRIPT" revert dotfiles-test-desktop
  else
    echo "No snapshot found. Creating desktop VM (first run)..."
    ./tests/vm/create.sh --desktop
    echo "Starting VM from snapshot..."
    "$SNAPSHOT_SCRIPT" revert dotfiles-test-desktop
  fi
  just test-vm testuser dotfiles-test-desktop
  result=$?
  if [ $result -eq 0 ]; then
    echo "Tests passed. VM left running for inspection."
  else
    echo "Tests failed. VM left running for inspection."
  fi
  exit $result