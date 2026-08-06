#!/bin/bash
#
# collect-openwrt-debug.sh - collect diagnostic information from an OpenWrt
# router over SSH and save it to a compact report file.
#
# Usage: collect-openwrt-debug.sh [router] [profile]

set -u

DEFAULT_ROUTER="${DEFAULT_ROUTER:-my-router}"
DEFAULT_PROFILE="${DEFAULT_PROFILE:-minimal}"
SSH_TIMEOUT="${SSH_TIMEOUT:-10}"
LOG_LINES="${LOG_LINES:-300}"
CONFIG_PACKAGES="${CONFIG_PACKAGES:-network wireless firewall dhcp system fstab}"
CUSTOM_DEFAULTS="${CUSTOM_DEFAULTS:-collect_system collect_resources collect_network collect_logs}"
CUSTOM_VALID="collect_system collect_resources collect_storage collect_network collect_config collect_logs"
SANITIZE="${SANITIZE:-1}"
MASK_SECRETS="${MASK_SECRETS:-1}"
MASK_IPS="${MASK_IPS:-1}"
MASK_MAC="${MASK_MAC:-1}"
MASK_IDENT="${MASK_IDENT:-1}"
SEP_LINE="======================================================================"

ROUTER=""
PROFILE=""
OUTPUT_FILE=""
BODY_FILE=""
SECTIONS=""

usage() {
  cat <<EOF
Usage: $(basename "$0") [router] [profile]

Collect diagnostic information from an OpenWrt router over SSH.

Arguments:
  router    SSH host from ~/.ssh/config (default: $DEFAULT_ROUTER)
  profile   One of: minimal normal full crash custom (default: $DEFAULT_PROFILE)

Options:
  -h, --help    Show this help and exit

Profiles:
  minimal   Compact report for small LLM contexts
  normal    minimal + lsmod + pstore
  full      normal + top + ps
  crash     Hang/crash investigation, more logs, no config
  custom    Custom set of collect_* functions

Custom profile:
  The set of functions is taken from the CUSTOM_DEFAULTS variable.
  Allowed values: $CUSTOM_VALID
  Current CUSTOM_DEFAULTS: $CUSTOM_DEFAULTS

Privacy:
  By default the report is sanitized: uci secrets, MAC addresses (OUI kept),
  IP addresses and hostname/SSID are masked. Set SANITIZE=0 to keep raw output.
  Toggles: MASK_SECRETS, MASK_IPS, MASK_MAC, MASK_IDENT (1 = on, 0 = off).
EOF
}

section() {
  local title="$1"
  printf '\n%s\n%s\n%s\n' "$SEP_LINE" "$title" "$SEP_LINE"
}

run_sh() {
  local name="$1"
  local script="$2"
  local rc
  local output
  SECTIONS="$SECTIONS$name"$'\n'
  section "$name" >> "$BODY_FILE"
  printf 'Command: %s\n' "$script" >> "$BODY_FILE"
  printf '\n' >> "$BODY_FILE"
  output="$(timeout "$SSH_TIMEOUT" ssh "$ROUTER" "$script" 2>&1)"
  rc=$?
  printf '%s\n' "$output" | sanitize >> "$BODY_FILE"
  if [ "$rc" -eq 124 ]; then
    printf '\nError: command timed out after %ss\n' "$SSH_TIMEOUT" >> "$BODY_FILE"
  elif [ "$rc" -ne 0 ]; then
    printf '\nError: command failed (exit code %d)\n' "$rc" >> "$BODY_FILE"
  fi
  printf '\n' >> "$BODY_FILE"
}

run() {
  local name="$1"
  local command="$2"
  run_sh "$name" "$command"
}

sanitize() {
  local data
  data="$(cat)"
  if [ "$SANITIZE" -ne 1 ]; then
    printf '%s\n' "$data"
    return
  fi
  if [ "$MASK_SECRETS" -eq 1 ]; then
    data="$(printf '%s\n' "$data" | sed -E "s/(option (key|psk|password|passwd|secret|private_key|preshared_key|awg_i1) ')[^']*/\1<redacted>/")"
  fi
  if [ "$MASK_MAC" -eq 1 ]; then
    data="$(printf '%s\n' "$data" | sed -E 's/([0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}):[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}/\1:xx:xx:xx/g')"
  fi
  if [ "$MASK_IPS" -eq 1 ]; then
    data="$(printf '%s\n' "$data" | sed -E \
      -e 's/([0-9]{1,3}\.[0-9]{1,3})\.[0-9]{1,3}\.[0-9]{1,3}/\1.x.x/g' \
      -e 's/(::)[0-9a-fA-F]{1,4}(:[0-9a-fA-F]{1,4}){3}/::xxxx:xxxx:xxxx:xxxx/g' \
      -e 's/([0-9a-fA-F]{1,4}(:[0-9a-fA-F]{1,4}){3}):[0-9a-fA-F]{1,4}(:[0-9a-fA-F]{1,4}){3}/\1:xxxx:xxxx:xxxx:xxxx/g')"
  fi
  if [ "$MASK_IDENT" -eq 1 ]; then
    data="$(printf '%s\n' "$data" | sed -E \
      -e 's/("hostname": ")[^"]*/\1host/' \
      -e "s/(option hostname ')[^']*/\1host/" \
      -e "s/(option ssid ')[^']*/\1ssid/")"
  fi
  printf '%s\n' "$data"
}

collect_system() {
  run 'System / board' 'ubus call system board'
  run 'System / openwrt_release' 'cat /etc/openwrt_release'
  run 'System / uname' 'uname -a'
  run 'System / uptime' 'uptime'
  run 'System / proc_version' 'cat /proc/version'
}

collect_resources() {
  run 'Resources / free' 'free'
  run 'Resources / df' 'df -h'
  run 'Resources / mount' 'mount'
  run 'Resources / loadavg' 'cat /proc/loadavg'
}

collect_storage() {
  run 'Storage / lsusb' 'lsusb'
  run 'Storage / block' 'block info'
  run 'Storage / blkid' 'blkid'
}

collect_network() {
  run 'Network / addr' 'ip addr'
  run 'Network / route' 'ip route'
  run 'Network / bridge' 'bridge link'
  run 'Network / system_info' 'ubus call system info'
}

collect_config() {
  local pkg
  for pkg in $CONFIG_PACKAGES; do
    run "Config / $pkg" "uci export $pkg"
  done
}

collect_logs() {
  run 'Logs / dmesg' "dmesg | tail -n $LOG_LINES"
  run 'Logs / logread' "logread | tail -n $LOG_LINES"
}

collect_lsmod() {
  run 'Kernel modules' 'lsmod'
}

collect_pstore() {
  run_sh 'Pstore' '
    if [ -d /sys/fs/pstore ]; then
      if ls -A /sys/fs/pstore 2>/dev/null | grep -q .; then
        ls -la /sys/fs/pstore
      else
        echo "No pstore files."
      fi
    else
      echo "/sys/fs/pstore not present."
    fi
  '
}

collect_top() {
  run 'Top' 'top -bn1'
}

collect_ps() {
  run 'Processes' 'ps | sort'
}

collect_minimal() {
  collect_system
  collect_resources
  collect_storage
  collect_network
  collect_config
}

collect_normal() {
  collect_minimal
  collect_lsmod
  collect_pstore
  collect_logs
}

collect_full() {
  collect_normal
  collect_top
  collect_ps
}

collect_crash() {
  LOG_LINES=1000
  collect_system
  collect_resources
  collect_storage
  collect_network
  collect_top
  collect_ps
  collect_lsmod
  collect_logs
  collect_pstore
}

collect_custom() {
  local fn
  local seen=""
  for fn in $CUSTOM_DEFAULTS; do
    case " $CUSTOM_VALID " in
      *" $fn "*)
        case " $seen " in
          *" $fn "*) ;;
          *)
            seen="$seen $fn"
            "$fn"
            ;;
        esac
        ;;
      *)
        printf 'Warning: ignoring unknown custom function "%s"\n' "$fn" >> "$BODY_FILE"
        ;;
    esac
  done
}

parse_args() {
  local arg_count=0
  local arg
  ROUTER="$DEFAULT_ROUTER"
  PROFILE="$DEFAULT_PROFILE"
  for arg in "$@"; do
    case "$arg" in
      -h|--help)
        usage
        exit 0
        ;;
      -*)
        printf 'Unknown option: %s\n' "$arg" >&2
        usage >&2
        exit 1
        ;;
      *)
        arg_count=$((arg_count + 1))
        if [ "$arg_count" -eq 1 ]; then
          ROUTER="$arg"
        elif [ "$arg_count" -eq 2 ]; then
          PROFILE="$arg"
        else
          printf 'Too many arguments.\n' >&2
          usage >&2
          exit 1
        fi
        ;;
    esac
  done
  case "$PROFILE" in
    minimal|normal|full|crash|custom) ;;
    *)
      printf 'Unknown profile: %s\n' "$PROFILE" >&2
      printf 'Allowed profiles: minimal normal full crash custom\n' >&2
      exit 1
      ;;
  esac
}

setup_report() {
  BODY_FILE="$(mktemp)" || exit 1
  trap 'rm -f "$BODY_FILE"' EXIT
  REPORT_DATE="$(date '+%Y-%m-%d %H:%M:%S')"
  OUTPUT_FILE="openwrt-debug-$PROFILE-$(date +%Y%m%d-%H%M%S).log"
}

finalize() {
  {
    printf '%s\n' 'OpenWrt Diagnostic Report'
    printf '\n'
    printf 'Router:  %s\n' "$ROUTER"
    printf 'Profile: %s\n' "$PROFILE"
    printf 'Date:    %s\n' "$REPORT_DATE"
    if [ "$SANITIZE" -eq 1 ]; then
      printf 'Privacy: sanitized\n'
    else
      printf 'Privacy: raw\n'
    fi
    printf '\n'
    printf '%s\n' 'Sections:'
    local n=0
    while IFS= read -r s; do
      [ -n "$s" ] || continue
      n=$((n + 1))
      printf '  %d. %s\n' "$n" "$s"
    done <<< "$SECTIONS"
    printf '\n'
    cat "$BODY_FILE"
  } > "$OUTPUT_FILE"
  chmod 600 "$OUTPUT_FILE"
  printf '\nFinished.\n\nOutput saved to:\n\n%s\n' "$OUTPUT_FILE"
}

main() {
  parse_args "$@"
  setup_report
  case "$PROFILE" in
    minimal)
      collect_minimal
      ;;
    normal)
      collect_normal
      ;;
    full)
      collect_full
      ;;
    crash)
      collect_crash
      ;;
    custom)
      collect_custom
      ;;
  esac
  finalize
}

main "$@"
