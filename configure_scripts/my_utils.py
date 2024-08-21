#!/usr/bin/env python3

import os
from os import path
import sys
import shutil
import logging
import inspect
import subprocess

def get_script_dir(follow_symlinks: bool = True):
  if getattr(sys, 'frozen', False): # py2exe, PyInstaller, cx_Freeze
    path = os.path.abspath(sys.executable)
  else:
    path = inspect.getabsfile(get_script_dir)
  if follow_symlinks:
    path = os.path.realpath(path)
  return os.path.dirname(path)

def check_python_version():
  logging.debug(sys.version)
  if sys.version_info < (3, 11):
    raise Exception("Must be using Python 3.11 or grater!")

def link_path(src: str, target_folder: str, backup_dir: str = '/tmp'):
  """
  Create or replace symbol link in target directory.
  Create backup for file/directory with same name as src.

  Parameters
  ----------
  src : str
      Absolute path for source file/directory
  target_folder : str
      Directory where symbol link will be created
  backup_dir : str, optional
      Directory for possible backup, by default '/tmp'
  """
  print(
    f"""
    Make symbolic link for {path.basename(src)}
    in {target_folder}
    """)
  path_for_backup = path.join(
    target_folder,
    path.basename(src)
  )
  maybe_backup(
    path_for_backup,
    backup_dir
  )

  subprocess.call([
    "ln",
    "-snf",
    f"--target-directory={target_folder}",
    src])

def maybe_backup(some_path: str, backup_dir: str):
  if(os.path.exists(some_path) and  not os.path.islink(some_path)):
    backup = path.join(
      backup_dir,
      path.basename(some_path) + ".backup"
    )
    os.makedirs(backup_dir, exist_ok=True)

    shutil.move(some_path, backup)
    print('Move to backup - ', backup)

if __name__ == "__main__":
  print(get_script_dir())