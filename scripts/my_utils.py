#!/usr/bin/env python
import os
import sys
import logging
import inspect

def get_script_dir(follow_symlinks=True):
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

if __name__ == "__main__":
  print(get_script_dir())