#!/usr/bin/env python3

import os
import argparse
import shutil
import time
import re

script_name = os.path.basename(__file__)
current_timestamp = time.strftime('%Y%m%d%H%M%S')

def create_backup(target_path: str):
  """
    Создаёт резервную копию файла.

    Parameters
    ----------
    target_path : string
        Файл для бэкапа.

    Returns
    -------
    string
        Путь к резервной копии.
    """
  backup_dir = '/tmp' if os.path.exists('/tmp') else os.path.expandvars('$HOME/backups')

  os.makedirs(backup_dir, exist_ok=True)

  backup_path = os.path.join(backup_dir,
                             f'{os.path.basename(target_path)}.{current_timestamp}.backup')

  shutil.copy2(target_path, backup_path)
  print(f'Резервная копия создана: {backup_path}')

  return backup_path


def is_alias_block_present(content: str, source_file: str):
  """
    Проверяет, добавлен ли уже блок с указанным файлом алиасов.

    Parameters
    ----------
    content : string
        Содержимое файла .bashrc.
    source_file : string
        Путь к файлу с алиасами.

    Returns
    -------
    bool
        True, если блок уже добавлен, иначе False.
    """
  return re.search(
      rf'if \[ -f {re.escape(source_file)} \]; then\n[ \t]*\. {re.escape(source_file)}\nfi',
      content)


def insert_alias_block(content: str, marker_pattern: str, inclusion_block: str):
  """
    Вставляет блок с алиасами после строки-маркера. Если маркер не найден,
    добавляет его в конец файла вместе с блоком алиасов.

    Parameters
    ----------
    content : string
        Содержимое файла .bashrc.
    marker_pattern : string
        Шаблон для поиска строки-маркера.
    inclusion_block : string
        Блок кода для добавления.
    script_name : string
        Имя текущего скрипта.

    Returns
    -------
    string
        Обновлённое содержимое файла .bashrc.
    """
  marker_found = re.search(marker_pattern, content)

  if marker_found:
    # Маркер найден - вставляем после него
    return content[:marker_found.end(
    )] + '\n\n' + inclusion_block + content[marker_found.end():]
  else:
    # Маркер не найден - добавляем в конец файла
    marker_line = f'# >>> insert by script {script_name} <<<\n'
    if not content.endswith('\n'):
      content += '\n'
    return content + '\n' + marker_line + '\n' + inclusion_block


def main(source_file: str, bashrc_path: str = '$HOME/.bashrc'):
  """
    Главная функция для добавления алиасов в .bashrc.

    Parameters
    ----------
    source_file : string
        Путь к файлу c алиасами.
    bashrc_path : string, optional
        Путь к файлу .bashrc для тестирования.
    """
  bashrc_path = os.path.expandvars(bashrc_path)
  marker_pattern = rf'# >>> insert by script {re.escape(script_name)} <<<'

  # Формируем блок кода для добавления
  inclusion_block = f'# Added by {script_name}\nif [ -f {source_file} ]; then\n    . {source_file}\nfi\n'

  # Если файл .bashrc существует, проверяем его содержимое
  if not os.path.exists(bashrc_path):
    print(f"Файл '{bashrc_path}' не существует.")
    return

  create_backup(bashrc_path)

  with open(bashrc_path, 'r', encoding='utf-8') as tf:
    content = tf.read()

    if is_alias_block_present(content, source_file):
      print(f"Алиасы из '{source_file}' уже подключены в {bashrc_path}.")
      return

    new_content = insert_alias_block(content, marker_pattern, inclusion_block)

    with open(bashrc_path, 'w', encoding='utf-8') as tf:
      tf.write(new_content)

    print(f"Добавлен блок алиасов из '{source_file}' в '{bashrc_path}'.")


def run_tests():
  """
    Запускает тесты для скрипта.
    """
  # Создаём уникальную папку для тестов с текущей датой и временем
  test_dir = os.path.join('/tmp', current_timestamp)
  os.makedirs(test_dir, exist_ok=True)

  test_file = '/tmp/example_bash_aliases'

  # Тест 1: Файл с маркером
  test1_path = os.path.join(test_dir, 'test1.bashrc')
  with open(test1_path, 'w', encoding='utf-8') as f:
    f.write(f"""# Test file
# >>> insert by script {script_name} <<<
Нужно вставить до этой строки
""")

  print("\nЗапуск теста 1: Проверка вставки после маркера")
  main(test_file, bashrc_path=test1_path)
  with open(test1_path, 'r', encoding='utf-8') as f:
    content = f.read()
    if f'if [ -f {test_file} ]; then' in content:
      print("Тест 1 пройден: Блок успешно вставлен после маркера.")
    else:
      print("Тест 1 не пройден: Блок не вставлен.")

  # Тест 2: Файл без маркера
  test2_path = os.path.join(test_dir, 'test2.bashrc')
  with open(test2_path, 'w', encoding='utf-8') as f:
    f.write("""# Test file without marker
Нужно вставить до этой строки
""")

  print("\nЗапуск теста 2: Проверка добавления маркера и блока в конец файла")
  main(test_file, bashrc_path=test2_path)
  with open(test2_path, 'r', encoding='utf-8') as f:
    content = f.read()
    if f'# >>> insert by script {script_name} <<<' in content and f'if [ -f {test_file} ]; then' in content:
      print("Тест 2 пройден: Маркер и блок добавлены в конец файла.")
    else:
      print("Тест 2 не пройден: Маркер и/или блок не добавлены.")

  # Тест 3: Файл с уже добавленным блоком
  test3_path = os.path.join(test_dir, 'test3.bashrc')
  with open(test3_path, 'w', encoding='utf-8') as f:
    f.write(f"""# Test file with existing block
# >>> insert by script {script_name} <<<
if [ -f {test_file} ]; then
    . {test_file}
fi
""")

  print("\nЗапуск теста 3: Проверка, что блок уже добавлен")
  main(test_file, bashrc_path=test3_path)
  with open(test3_path, 'r', encoding='utf-8') as f:
    content = f.read()
    if content.count(f'if [ -f {test_file} ]; then') == 1:
      print("Тест 3 пройден: Блок уже добавлен, файл не изменён.")
    else:
      print("Тест 3 не пройден: Файл изменён, хотя блок уже присутствует.")


if __name__ == "__main__":
  parser = argparse.ArgumentParser(
      description=
      f"Добавляет блок с указанным файлом алиасов в .bashrc после строки-маркера.\n"
      f"Если строка-маркер '# >>> insert by script {script_name} <<<' не найдена,\n"
      "она будет добавлена в конец файла вместе с блоком алиасов.",
      epilog=f"",
      formatter_class=argparse.RawTextHelpFormatter)
  parser.add_argument('-s',
                      '--source-file',
                      type=str,
                      required=False,
                      help="Путь к файлу с алиасами")
  parser.add_argument('-t', '--tests', action='store_true', help="Запуск тестов")

  args = parser.parse_args()

  if args.tests:
    run_tests()
  elif args.source_file:
    source_file = os.path.abspath(args.source_file)
    if not os.path.exists(source_file):
      print(f"Файл '{source_file}' не существует.")
      exit(1)
    main(source_file)
  else:
    parser.print_help()
