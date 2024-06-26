#!/usr/bin/env python

import os
import subprocess
import shutil
from os import path
from os.path import abspath
from my_utils import check_python_version

"""
Create link for home-manager main config file
"""


check_python_version()

# Init vars
dir = os.path.dirname(__file__)
home_nix = abspath(path.join(dir, "../home/home.nix"))
td = path.expandvars('$HOME/.config/home-manager')

def link_path(src: str, target_folder: str, backup_dir='/tmp'):
  """
  Create symbol link in target directory.
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
    link_path(home_nix, td)