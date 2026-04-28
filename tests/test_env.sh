#!/usr/bin/env bash
source "$(dirname "$0")/helpers.sh"

CONF_FILE="$HOME/.my_scripts.conf"

echo "--- Environment config ---"
assert_file "$CONF_FILE"

if [ -f "$CONF_FILE" ]; then
  source "$CONF_FILE"
  if [ -n "${MYSCRIPTS:-}" ]; then
    echo -e "  ${GREEN}✓${NC} MYSCRIPTS=$MYSCRIPTS"; ((PASSED++))
  else
    echo -e "  ${RED}✗${NC} MYSCRIPTS not set"; ((FAILED++))
  fi
  if [ -n "${WORKSCRIPTS:-}" ]; then
    echo -e "  ${GREEN}✓${NC} WORKSCRIPTS=$WORKSCRIPTS"; ((PASSED++))
  else
    echo -e "  ${RED}✗${NC} WORKSCRIPTS not set"; ((FAILED++))
  fi
fi

echo "--- Aliases in .bashrc ---"
if [ -f "$HOME/.bashrc" ]; then
  if grep -q "scripts/aliases/bash_aliases" "$HOME/.bashrc" 2>/dev/null \
     || grep -q "insert_aliases" "$HOME/.bashrc" 2>/dev/null; then
    echo -e "  ${GREEN}✓${NC} bash_aliases sourced in .bashrc"; ((PASSED++))
  else
    echo -e "  ${RED}✗${NC} bash_aliases not found in .bashrc"; ((FAILED++))
  fi
fi

print_results
