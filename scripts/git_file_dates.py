#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Даты файлов в Git

Показывает дату добавления(изменения имени) и последнего изменения файла.
Есть JSON вывод.
"""

import argparse
import subprocess
import sys
import os
import json
from datetime import datetime

def run_git_command(args: list[str]) -> str:
  try:
    return subprocess.check_output(args, text=True).strip()
  except subprocess.CalledProcessError:
    return ""

def is_git_repo() -> bool:
  result = run_git_command(["git", "rev-parse", "--is-inside-work-tree"])
  return result == "true"

def file_tracked(file_path: str) -> bool:
  result = run_git_command(["git", "ls-files", "--error-unmatch", file_path])
  return bool(result)

def format_date(date_str: str) -> str:
  """Форматирует YYYY-MM-DD → YYYY-MMM-DD"""
  try:
    d = datetime.strptime(date_str, "%Y-%m-%d")
    return d.strftime("%Y-%b-%d")
  except ValueError:
    return date_str

def git_date_created(file_path: str) -> str:
  """Возвращает дату первого коммита файла (создания)"""
  result = run_git_command(
    ["git", "log", "--diff-filter=A", "--format=%cd", "--date=short", "--reverse", "--", file_path]
  )
  if result:
    raw = result.splitlines()[0]
    return f"{raw} → {format_date(raw)}"
  return "N/A"

def git_date_updated(file_path: str) -> str:
  """Возвращает дату последнего изменения файла"""
  result = run_git_command(
    ["git", "log", "-1", "--format=%cd", "--date=short", "--", file_path]
  )
  if result:
    return f"{result} → {format_date(result)}"
  return "N/A"

def main() -> int:
  parser = argparse.ArgumentParser(
    description="Вывести дату добавления и последнего изменения файла в git."
  )
  parser.add_argument(
    "file",
    type=str,
    help="Путь к файлу в репозитории (строка)"
  )
  parser.add_argument(
    "--json",
    action="store_true",
    help="Вывод в формате JSON (только YYYY-MM-DD)"
  )
  args = parser.parse_args()

  if not is_git_repo():
    print("Ошибка: текущая директория не является git-репозиторием.", file=sys.stderr)
    return 1

  if not os.path.exists(args.file):
    print(f"Ошибка: файл '{args.file}' не существует.", file=sys.stderr)
    return 1

  if not file_tracked(args.file):
    print(f"Ошибка: файл '{args.file}' не отслеживается git.", file=sys.stderr)
    return 1

  # для JSON нужны "сырые" даты
  created_raw = run_git_command(
    ["git", "log", "--diff-filter=A", "--format=%cd", "--date=short", "--reverse", "--", args.file]
  ).splitlines()[0]
  updated_raw = run_git_command(
    ["git", "log", "-1", "--format=%cd", "--date=short", "--", args.file]
  )

  if args.json:
    print(json.dumps({"created": created_raw, "updated": updated_raw}, ensure_ascii=False))
  else:
    created = f"{created_raw} → {format_date(created_raw)}" if created_raw else "N/A"
    updated = f"{updated_raw} → {format_date(updated_raw)}" if updated_raw else "N/A"
    print(f"Created: {created}")
    print(f"Updated: {updated}")

  return 0

if __name__ == "__main__":
  sys.exit(main())
