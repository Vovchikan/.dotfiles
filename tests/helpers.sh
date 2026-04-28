#!/usr/bin/env bash

PASSED=0
FAILED=0

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

assert_link() {
  local target=$1 expected=$2
  if [ -L "$target" ] && [ "$(readlink "$target")" = "$expected" ]; then
    echo -e "  ${GREEN}✓${NC} $target → $expected"; ((PASSED++))
  else
    local actual
    actual=$(readlink "$target" 2>/dev/null || echo "not a symlink")
    echo -e "  ${RED}✗${NC} $target → $actual ${RED}[expected: $expected]${NC}"; ((FAILED++))
  fi
}

assert_file() {
  local path=$1
  if [ -f "$path" ]; then
    echo -e "  ${GREEN}✓${NC} $path exists"; ((PASSED++))
  else
    echo -e "  ${RED}✗${NC} $path not found"; ((FAILED++))
  fi
}

assert_dir() {
  local path=$1
  if [ -d "$path" ]; then
    echo -e "  ${GREEN}✓${NC} $path exists"; ((PASSED++))
  else
    echo -e "  ${RED}✗${NC} $path not found"; ((FAILED++))
  fi
}

assert_git_config() {
  local key=$1 expected=$2
  local actual
  actual=$(git config --global "$key" 2>/dev/null || echo "__unset__")
  if [ "$actual" = "$expected" ]; then
    echo -e "  ${GREEN}✓${NC} git $key = $expected"; ((PASSED++))
  else
    echo -e "  ${RED}✗${NC} git $key = $actual ${RED}[expected: $expected]${NC}"; ((FAILED++))
  fi
}

print_results() {
  echo
  if [ "$FAILED" -eq 0 ]; then
    echo -e "${GREEN}=== All $PASSED tests passed ===${NC}"
    return 0
  else
    echo -e "${RED}=== $PASSED passed, $FAILED failed ===${NC}"
    return 1
  fi
}
