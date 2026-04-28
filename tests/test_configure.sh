#!/usr/bin/env bash
source "$(dirname "$0")/helpers.sh"

echo "--- Git config ---"
assert_git_config "user.name"       "Vladimir Samorodov"
assert_git_config "user.email"      "vovchikan@gmail.com"
assert_git_config "core.editor"     "vim"
assert_git_config "pull.ff"         "only"
assert_git_config "alias.s"         "status"
assert_git_config "alias.lol"       "log --oneline"
assert_git_config "alias.fixup"     "commit --amend --no-edit"
assert_git_config "alias.hide"      "update-index --skip-worktree"
assert_git_config "alias.assume"    "update-index --assume-unchanged"

echo "--- Gitk theme (optional) ---"
if [ -f "$HOME/.config/git/gitk" ]; then
  echo -e "  ${GREEN}✓${NC} $HOME/.config/git/gitk exists"; ((PASSED++))
else
  echo "  - skipped (gitk.sh not run in sandbox)"
fi

print_results
