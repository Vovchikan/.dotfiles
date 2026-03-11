#!/usr/bin/env bash

ADD_FLAGS=false
FILE_NAME=""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 1
TEMPLATE_DIR="$SCRIPT_DIR/../templates"

usage() {
  echo "Usage: $0 [options] <filename>"
  echo
  echo "Options:"
  echo "  -F, --flags      Create script with CLI flags template"
  echo "  -h, --help       Show this help"
}

# разбор аргументов
while [[ $# -gt 0 ]]; do
  case "$1" in
    -F|--flags)
      ADD_FLAGS=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      echo "Unknown option: $1"
      usage
      exit 1
      ;;
    *)
      if [[ -n "$FILE_NAME" ]]; then
        echo "Error: multiple filenames given"
        usage
        exit 1
      fi
      FILE_NAME="$1"
      shift
      ;;
  esac
done

if [[ -z "$FILE_NAME" ]]; then
  usage
  exit 1
fi

if [[ -e "$FILE_NAME" ]]; then
  echo "Error: file '$FILE_NAME' already exists."
  exit 1
fi

EXT="${FILE_NAME##*.}"

if $ADD_FLAGS && [[ -f "$TEMPLATE_DIR/$EXT.template" ]]; then
  cp "$TEMPLATE_DIR/$EXT.template" "$FILE_NAME"
else
  case "$EXT" in
    sh)
      echo "#!/usr/bin/env bash" > "$FILE_NAME"
      ;;
    py)
      echo "#!/usr/bin/env python3" > "$FILE_NAME"
      ;;
    *)
      touch "$FILE_NAME"
      ;;
  esac
fi

chmod 755 "$FILE_NAME"