#!/usr/bin/env bash
source "$(dirname "$0")/helpers.sh"

ALIASES_FILE="$DOTFILES_DIR/scripts/aliases/bash_aliases"
ALIASES=$(bash -c "
  shopt -s expand_aliases
  [ -f ~/.my_scripts.conf ] && source ~/.my_scripts.conf
  source '$ALIASES_FILE'
  alias
" 2>/dev/null)

echo "--- Aliases ---"
for pair in \
  "gitka=gitk --all &" \
  "gitfdates=\$MYSCRIPTS/tools/git_file_dates.py" \
  "update-list=source \$MYSCRIPTS/tools/utils.sh; apt_update" \
  "list-size=du -h --max-depth=1" \
  "show-linux=\$MYSCRIPTS/tools/linux-info.sh" \
  "clipf=cat \"\$1\" | xclip" \
  "mc=LANG=C.utf8 mc"
do
  name="${pair%%=*}"
  if echo "$ALIASES" | grep -q "alias $name="; then
    echo -e "  ${GREEN}✓${NC} $name"
    ((PASSED++))
  else
    echo -e "  ${RED}✗${NC} $name not defined"
    ((FAILED++))
  fi
done

print_results
