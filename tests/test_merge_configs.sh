#!/usr/bin/env bash
source "$(dirname "$0")/helpers.sh"

SCRIPT="$(dirname "$0")/../helpers/merge_keepassxc.py"
TEMPLATE="$(dirname "$0")/../app_configs/keepassxc/keepassxc.ini"
TMPDIR=$(mktemp -d "/tmp/keepassxc-test-XXXXXX")
trap 'rm -rf "$TMPDIR"' EXIT

TARGET="$TMPDIR/keepassxc.ini"
LOG="$TMPDIR/merge.log"

echo "--- KeepassXC: create from template ---"
EXIT=0
python3 "$SCRIPT" --template "$TEMPLATE" --target "$TARGET" --log "$LOG" >/dev/null 2>&1 || EXIT=$?
assert_return 1 $EXIT
assert_file "$TARGET"

echo "--- KeepassXC: unchanged on second run ---"
EXIT=0
python3 "$SCRIPT" --template "$TEMPLATE" --target "$TARGET" --log "$LOG" >/dev/null 2>&1 || EXIT=$?
assert_return 0 $EXIT

echo "--- KeepassXC: merge missing key ---"
cat > "$TARGET" <<'INI'
[General]
DropToBackgroundOnCopy=true
HideWindowOnCopy=true
MinimizeOnCopy=false

[Browser]
CustomProxyLocation=
Enabled=false

[KeeShare]
Active="<xml>"
INI
EXIT=0
python3 "$SCRIPT" --template "$TEMPLATE" --target "$TARGET" --log "$LOG" >/dev/null 2>&1 || EXIT=$?
assert_return 1 $EXIT
grep -q "^ConfigVersion=2$" "$TARGET" && echo -e "  ${GREEN}✓${NC} missing key added" && ((PASSED++)) \
  || { echo -e "  ${RED}✗${NC} missing key not added"; ((FAILED++)); }
grep -q "^Enabled=true$" "$TARGET" && echo -e "  ${GREEN}✓${NC} value updated" && ((PASSED++)) \
  || { echo -e "  ${RED}✗${NC} value not updated"; ((FAILED++)); }
grep -q '^Active="<xml>"$' "$TARGET" && echo -e "  ${GREEN}✓${NC} KeeShare preserved" && ((PASSED++)) \
  || { echo -e "  ${RED}✗${NC} KeeShare modified"; ((FAILED++)); }

echo "--- KeepassXC: backup created ---"
BACKUP=$(ls /tmp/keepassxc.ini.bak.* 2>/dev/null | sort | tail -1 || true)
[ -n "$BACKUP" ] && echo -e "  ${GREEN}✓${NC} backup $BACKUP" && ((PASSED++)) \
  || { echo -e "  ${RED}✗${NC} no backup created"; ((FAILED++)); }

echo "--- KeepassXC: error on missing template ---"
EXIT=0
python3 "$SCRIPT" --template "$TMPDIR/nope.ini" --target "$TARGET" --log "$LOG" >/dev/null 2>&1 || EXIT=$?
assert_return 2 $EXIT
assert_file "$LOG"

echo "--- KeepassXC: version ---"
VERSION_OUT=$(python3 "$SCRIPT" --version)
[ "$VERSION_OUT" = "0.1" ] && echo -e "  ${GREEN}✓${NC} version $VERSION_OUT" && ((PASSED++)) \
  || { echo -e "  ${RED}✗${NC} version $VERSION_OUT ${RED}[expected: 0.1]${NC}"; ((FAILED++)); }

print_results