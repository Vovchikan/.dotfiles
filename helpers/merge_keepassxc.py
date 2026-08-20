#!/usr/bin/env python3

import argparse
import os
import shutil
import sys
import time
from typing import Dict, List, Optional, Tuple

VERSION = "0.1"

DEFAULT_TEMPLATE = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "../app_configs/keepassxc/keepassxc.ini"))
DEFAULT_TARGET = os.path.expanduser("~/.config/keepassxc/keepassxc.ini")
DEFAULT_LOG = "/tmp/merge-configs.log"

EXIT_UNCHANGED = 0
EXIT_CHANGED = 1
EXIT_ERROR = 2

Section = Optional[str]
Body = List[str]


def parse_template(template_path: str) -> Dict[str, Dict[str, str]]:
  sections: Dict[str, Dict[str, str]] = {}
  current: Optional[str] = None
  with open(template_path, "r") as f:
    for line in f:
      line = line.rstrip("\n")
      stripped = line.strip()
      if stripped.startswith("[") and stripped.endswith("]"):
        current = stripped[1:-1]
        sections.setdefault(current, {})
      elif "=" in line and current is not None:
        key, value = line.split("=", 1)
        sections[current][key.strip()] = value.strip()
  return sections


def parse_target(lines: List[str]) -> List[Tuple[Section, Body]]:
  sections: List[Tuple[Section, Body]] = []
  current: Section = None
  body: Body = []
  for line in lines:
    stripped = line.strip()
    if stripped.startswith("[") and stripped.endswith("]"):
      if current is not None or body:
        sections.append((current, body))
      current = stripped[1:-1]
      body = []
    else:
      body.append(line)
  if current is not None or body:
    sections.append((current, body))
  return sections


def find_key_in_body(body: Body, key: str) -> Optional[int]:
  for i, line in enumerate(body):
    stripped = line.strip()
    if "=" in line and not stripped.startswith((";", "#")):
      line_key = line.split("=", 1)[0].strip()
      if line_key == key:
        return i
  return None


def last_key_value_index(body: Body) -> Optional[int]:
  for i in range(len(body) - 1, -1, -1):
    line = body[i]
    stripped = line.strip()
    if "=" in line and not stripped.startswith((";", "#")):
      return i
  return None


def render_target(sections: List[Tuple[Section, Body]]) -> str:
  parts: List[str] = []
  for name, body in sections:
    if name is None:
      parts.extend(body)
    else:
      parts.append(f"[{name}]")
      parts.extend(body)
  return "\n".join(parts) + "\n"


def render_sections(sections: Dict[str, Dict[str, str]]) -> str:
  blocks: List[str] = []
  for name, keys in sections.items():
    block = [f"[{name}]"] + [f"{k}={v}" for k, v in keys.items()]
    blocks.append("\n".join(block))
  return "\n\n".join(blocks) + "\n"


def backup_path(target_path: str) -> str:
  stamp = time.strftime("%Y%m%d-%H%M%S")
  return f"/tmp/{os.path.basename(target_path)}.bak.{stamp}"


def write_log(log_path: str, message: str) -> None:
  with open(log_path, "a") as f:
    f.write(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] {message}\n")


def merge_config(template_path: str, target_path: str) -> Tuple[Optional[str], bool]:
  template_sections = parse_template(template_path)

  if not os.path.exists(target_path):
    os.makedirs(os.path.dirname(target_path), exist_ok=True)
    with open(target_path, "w") as f:
      f.write(render_sections(template_sections))
    return None, True

  with open(target_path, "r") as f:
    lines = f.read().splitlines()

  sections = parse_target(lines)
  changed = False

  for section_name, keys in template_sections.items():
    target_sec = next((s for s in sections if s[0] == section_name), None)
    if target_sec is None:
      sections.append((section_name, [f"{k}={v}" for k, v in keys.items()]))
      changed = True
      continue

    body = target_sec[1]
    for key, value in keys.items():
      idx = find_key_in_body(body, key)
      if idx is None:
        insert_at = last_key_value_index(body)
        new_line = f"{key}={value}"
        if insert_at is None:
          body.insert(0, new_line)
        else:
          body.insert(insert_at + 1, new_line)
        changed = True
      else:
        new_line = f"{key}={value}"
        if body[idx] != new_line:
          body[idx] = new_line
          changed = True

  if not changed:
    return None, False

  backup = backup_path(target_path)
  shutil.copy2(target_path, backup)
  with open(target_path, "w") as f:
    f.write(render_target(sections))
  return backup, True


def main() -> None:
  parser = argparse.ArgumentParser(
      description=
      "Мержит сохранённые настройки KeePassXC в ~/.config/keepassxc/keepassxc.ini")
  parser.add_argument("-v", "--version", action="version", version=VERSION)
  parser.add_argument("--template",
                      default=DEFAULT_TEMPLATE,
                      help="Путь к шаблону настроек")
  parser.add_argument("--target",
                      default=DEFAULT_TARGET,
                      help="Путь к целевому конфигу")
  parser.add_argument("--log", default=DEFAULT_LOG, help="Путь к файлу лога")
  args = parser.parse_args()

  try:
    backup, changed = merge_config(args.template, args.target)
  except Exception as e:
    write_log(args.log, f"Ошибка в {args.target}: {e}")
    print(f"Ошибка, подробности в логе: {args.log}", file=sys.stderr)
    sys.exit(EXIT_ERROR)

  if changed:
    print(f"Конфиг {args.target} обновлён.")
    if backup:
      print(f"Бэкап: {backup}")
    sys.exit(EXIT_CHANGED)

  print(f"Конфиг {args.target} актуален, изменения не требуются.")
  sys.exit(EXIT_UNCHANGED)


if __name__ == "__main__":
  main()
