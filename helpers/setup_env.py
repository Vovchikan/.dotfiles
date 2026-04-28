#!/usr/bin/env python3
import os
import argparse
from typing import Dict

DEFAULT_CONFIG: Dict[str, str] = {
    "export MYSCRIPTS": os.path.abspath(os.path.join(os.path.dirname(__file__), "../scripts")),
    "export WORKSCRIPTS": os.path.abspath(os.path.join(os.path.dirname(__file__), "../work-scripts"))
}

TARGET_CONF: str = os.path.expanduser("~/.my_scripts.conf")


def load_conf(conf_file: str) -> Dict[str, str]:
  env: Dict[str, str] = {}
  if os.path.exists(conf_file):
    with open(conf_file, "r") as f:
      for line in f:
        line = line.strip()
        if line and "=" in line and not line.startswith("#"):
          key, val = line.split("=", 1)
          env[key] = val.strip('"')
  return env


def save_conf(conf_file: str, env: Dict[str, str]) -> None:
  with open(conf_file, "w") as f:
    for key, val in env.items():
      f.write(f'{key}="{val}"\n')


def print_conf(env: Dict[str, str]) -> None:
  print("Текущая конфигурация:")
  for k, v in env.items():
    print(f"{k}={v}")


def main() -> None:
  parser: argparse.ArgumentParser = argparse.ArgumentParser(
      description=
      "Формирует ~/.my_scripts.conf на основе DEFAULT_CONFIG, внешнего конфига и аргументов"
  )
  parser.add_argument(
      "-c",
      "--config",
      help=
      "Путь к дополнительному файлу конфигурации, значения из которого будут объединены с DEFAULT_CONFIG"
  )
  parser.add_argument("--print",
                      action="store_true",
                      help="Вывести итоговую конфигурацию без сохранения")
  parser.add_argument(
      "vars",
      nargs="*",
      help='Переменные в формате KEY=VALUE или "export KEY=VALUE". Перезаписывают все предыдущие значения.')
  args: argparse.Namespace = parser.parse_args()

  config: Dict[str, str] = DEFAULT_CONFIG.copy()

  if args.config:
    external: Dict[str, str] = load_conf(os.path.expanduser(args.config))
    config.update(external)

  for item in args.vars:
    if "=" not in item:
      print(f'Неверный формат: {item}, ожидается "export KEY=VALUE" или "KEY=VALUE"')
      continue
    key, val = item.split("=", 1)
    config[key] = os.path.expanduser(val)

  if args.print:
    print_conf(config)
  else:
    save_conf(TARGET_CONF, config)
    print(f"Файл {TARGET_CONF} обновлён.")
    print_conf(config)
    print("\nУбедитесь, что в ~/.bash_aliases есть строка:")
    print(f"[ -f {TARGET_CONF} ] && source {TARGET_CONF}")
    print("Чтобы применить изменения сразу: source ~/.bashrc")


if __name__ == "__main__":
  main()
