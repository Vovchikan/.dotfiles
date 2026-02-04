#!/usr/bin/env python3
import argparse
import sys
from pathlib import Path


def rename_files(old_name: str, new_name: str) -> None:
  cwd: Path = Path(".").resolve()
  renamed: int = 0

  for path in cwd.rglob(f"{old_name}.*"): # рекурсивный поиск
    if not path.is_file():
      continue

    ext: str = path.suffix  # включая точку
    new_path: Path = path.with_name(f"{new_name}{ext}")

    if new_path.exists():
      print(f"[SKIP] {new_path} уже существует", file=sys.stderr)
      continue

    print(f"[RENAME] {path} → {new_path}")
    path.rename(new_path)
    renamed += 1

  if renamed == 0:
    print("Файлы не найдены.")
  else:
    print(f"Готово: переименовано {renamed} файл(ов).")


def main() -> None:
  parser: argparse.ArgumentParser = argparse.ArgumentParser(
      description="Рекурсивно переименовывает файлы с заданным именем, сохраняя расширение.")
  parser.add_argument("old_name", help="Старое имя файла (без расширения)")
  parser.add_argument("new_name", help="Новое имя файла (без расширения)")
  args = parser.parse_args()

  rename_files(args.old_name, args.new_name)


if __name__ == "__main__":
  main()
