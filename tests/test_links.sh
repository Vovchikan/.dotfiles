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

print_results
