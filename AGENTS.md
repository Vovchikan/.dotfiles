# AGENTS.md — dotfiles repo guidance

## Core facts

- **Task runner**: `just` (Justfile at root). Primary commands use `just <task>`.
- **Test runner**: `./tests/run.sh --live` (host check) or `--sandbox` (isolated `/tmp/dotfiles-sandbox-XXXXXX`)
- **VM testing**: Auto-detects VM IP via `virsh domifaddr`; deploys via SCP with `StrictHostKeyChecking=accept-new` (no host key prompt)
- **Env & aliases**: `~/.my_scripts.conf` exports `$MYSCRIPTS`, `$WORKSCRIPTS`; custom bash aliases in `scripts/aliases/bash_aliases`
- **Submodules**: `work-scripts` (git@github.com:Vovchikan/work-scripts.git), `kitty/theme` (catppuccin)

## Exact commands / shortcuts

- List tasks: `just --list --justfile Justfile`
- Run single test: `bash tests/test_*.sh` (e.g., `bash tests/test_links.sh`)
- Check VM IP: `virsh domifaddr <vm-name>`
- View aliases: `cat $MYSCRIPTS/aliases/bash_aliases`
- Host key: always accepted (`accept-new`); skip prompts with `StrictHostKeyChecking=accept-new`

## Required command order (apply-then-test)

**Standard apply flow:**

1. `just configure-git` → global Git config (`user.name`, `alias.hide`, `alias.unhide`, etc.)
2. `just link-configs` → symlinks in `~/.config/` and `~/.local/share/konsole/`
3. `just setup-env` → writes `~/.my_scripts.conf` with `$MYSCRIPTS`, `$WORKSCRIPTS`
4. `just insert-aliases` → bash aliases from `scripts/aliases/bash_aliases` (includes `work-scripts/funbox/` fallback)
5. `tests/run.sh --live` → verifies everything applied

**Test commands:**

- `just test` — run tests on host (`./tests/run.sh --live`)
- `just test-sandbox` — run in isolated sandbox
- `just test-vm` — deploy + test on headless VM (auto-detects IP)
- `just test-vm-desktop` — deploy + test on KDE VM (uses snapshot for speed)
- `just test-vm-fullcycle` — create → deploy → destroy headless VM

## Prerequisites

- `just` via `snap install --edge --classic just`
- Python venv: `make venv` installs `yapf`, `platformdirs` from `helpers/requirements.txt`
- VM tools: `virsh`, `virt-install`, `qemu-img`, `genisoimage`, SSH key at `~/.ssh/id_ed25519.pub` (or `$SSH_KEY`)
- Cloud image: Ubuntu 24.04 cached in `~/.cache/dotfiles-test/`

## Architecture / monorepo boundaries

| Component     | Path(s)            | Purpose                                                                        |
| ------------- | ------------------ | ------------------------------------------------------------------------------ |
| Root config   | `Justfile`         | All task definitions (10 tasks)                                                |
| Helpers       | `helpers/`         | Python (`setup_env.py`, `insert_aliases.py`), `requirements.txt`               |
| Configs       | `app_configs/`     | vim, tmux, mc, konsole, zed — `link.sh` creates symlinks in `~/.config/<app>/` |
| Scripts       | `scripts/`         | `aliases/bash_aliases`, `tools/`                                               |
| Install       | `install_scripts/` | `main.sh` (apps), `cargo.sh`, `vscode.sh`                                      |
| Configuration | `configure/`       | `main.sh`, `git.sh` (global git config), `my_utils.py`                         |
| Tests         | `tests/`           | `run.sh` (runner), `test_*.sh` suites, `vm/create.sh`, `vm/snapshot.sh`        |
| Work scripts  | `work-scripts/`    | Aligned for bash scripts (`funbox/` fallback)                                  |

## Git / workflow quirks

- **Git aliases hidden**: `hide` → `update-index --skip-worktree`, `unhide` → `update-index --no-skip-worktree`, `gitka`
- **Commit messages**: [Conventional Commits](https://www.conventionalcommits.org/) — `<type>(<scope>): <description>`. Always in **English**. Types: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `ci`, `style`, `perf`. Scope optional. Description — imperative, no capital letter, no trailing period.
- **Snap**: `just` via `snap install --edge --classic just`
- **Host key**: disabled globally (`accept-new`, `UserKnownHostsFile=/dev/null`) across all SSH
- **Sandbox**: minimal `.bashrc` with Git aliases pre-config; cleanup `rm -rf /tmp/dotfiles-sandbox-XXXXXX`

## VM testing quirks

- **Snapshots**: `tests/vm/snapshot.sh` (create/revert/has/delete); desktop VM has `clean` snapshot
- **First run**: `test-vm-desktop` creates VM + cloud-init (5–15 min for KDE Plasma), then creates snapshot
- **Subsequent runs**: `revert to snapshot` → fast load (1–2 sec) → tests
- **VMs left after test**: stay running for inspection; next run reverts to clean
- **Cloud-init**: runs `snap install --edge --classic just`, KDE Plasma (desktop), or just packages (headless)

## Repo-specific conventions

- **Shebangs**: `#!/usr/bin/env bash`/`#!/usr/bin/env python3` on scripts; `just` for tasks
- **Script templates**: new scripts should be based on templates from `scripts/tools/templates/` when applicable
- **Error handling**: `set -Eeuo pipefail` on test/run scripts
- **Paths**: absolute paths in Python scripts (`os.path.abspath()`); `~/.my_scripts.conf` for shared config
- **VM names**: `dotfiles-test` (headless, 4GB RAM), `dotfiles-test-desktop` (KDE, 8GB RAM + snapshot `clean`)
- **Test output**: helpers.sh uses color markers (`RED`, `GREEN`) for pass/fail

## Toolchain quirks & gotchas

- **Make → Just**: `Makefile` mostly deprecated; `make venv`/`requirements` migrated to `just venv`
- **Python helpers**: `yapf`, `platformdirs` in `helpers/requirements.txt`
- **Non-interactive TODO**: `main.sh`/`configure/main.sh` have `read -p` dialogs; `--non-interactive` not impl. yet
- **Image caching**: Ubuntu cloud img cached locally (accelerates VM creation)

## Existing instruction files

- **Root**: `README.md` (detailed instructions, tables, VM lifecycle, TODO), `Justfile` (10 task defs)
- **No AGENTS.md before** → being created now
- **No opencode.json** → not relevant for this repo
