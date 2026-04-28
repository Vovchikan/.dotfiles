#!/usr/bin/env python

import os
from datetime import datetime

from link import link_path
from my_utils import check_python_version


check_python_version()

name = "konsole"
home = os.path.expandvars('$HOME')
home_relative_target = ".local/share"
script_dir = os.path.dirname(__file__)
src = os.path.normpath(
  f"{script_dir}/../{name}/{home_relative_target}/{name}"
)
target_dir = os.path.join(
  home,
  home_relative_target
)

now_string = datetime.now().strftime("%Y-%m-%d_%H:%M:%S")
backup_dir = f"{home}/backups/{name}_{now_string}"

# print(f"""
#       home = {home}
#       src = {src}
#       target_dir = {target_dir}
#       backup_dir = {backup_dir}
#       """)
link_path(src, target_dir, backup_dir)