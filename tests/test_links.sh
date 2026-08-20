#!/usr/bin/env bash
source "$(dirname "$0")/helpers.sh"

echo "--- Vim ---"
assert_link "$HOME/.vimrc" "$DOTFILES_DIR/app_configs/vim/.vimrc"
assert_link "$HOME/.vim"   "$DOTFILES_DIR/app_configs/vim/.vim"

echo "--- Tmux ---"
assert_link "$HOME/.tmux.conf" "$DOTFILES_DIR/app_configs/tmux/.tmux.conf"
assert_link "$HOME/.tmux"      "$DOTFILES_DIR/app_configs/tmux/.tmux"

echo "--- Midnight Commander ---"
assert_link "$HOME/.config/mc" "$DOTFILES_DIR/app_configs/mc/.config/mc"
assert_file "$HOME/.config/mc/ini"
assert_file "$HOME/.config/mc/mc.ext.ini"
assert_file "$HOME/.config/mc/mc.keymap"

echo "--- Konsole ---"
assert_file "$HOME/.local/share/konsole/MyDefault.profile"

echo "--- VSCode ---"
assert_link "$HOME/.config/Code/User/settings.json"   "$DOTFILES_DIR/app_configs/vscode/.config/Code/User/settings.json"
assert_link "$HOME/.config/Code/User/keybindings.json" "$DOTFILES_DIR/app_configs/vscode/.config/Code/User/keybindings.json"

print_results
