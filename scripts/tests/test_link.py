#!/usr/bin/env python

import os
import sys
import time
import shutil


here = os.path.dirname(__file__)

sys.path.append(os.path.join(here, '..'))

from link import link_path

def test_dir_path():
  test_src = os.path.join(
    os.path.dirname(__file__),
    'test_src_dir_' + str(time.time())
  )
  test_target = os.path.join(
    os.path.dirname(__file__),
    'test_target_dir_' + str(time.time())
  )
  os.mkdir(test_src)
  os.mkdir(test_target)
  link_path(test_src, test_target)

  assert os.path.isdir(
    os.path.join(
      test_target,
      os.path.basename(test_src)
    )
  ) == True, f"Should create symbol link of directory ${os.path.basename(test_src)}\n in folder - ${test_target}"

  shutil.rmtree(test_src)
  shutil.rmtree(test_target)

def test_file_path():
  test_src = os.path.join(
    os.path.dirname(__file__),
    'test_src_file_' + str(time.time())
  )
  test_target = os.path.join(
    os.path.dirname(__file__),
    'test_target_dir_' + str(time.time())
  )
  os.mkdir(test_target)
  try:
    with open(test_src, 'x') as file:
        file.write("Hello, Geeks!")
  except FileExistsError:
      print(f"The file '{test_src}' already exists.")

  link_path(test_src, test_target)

  assert os.path.islink(
    os.path.join(
      test_target,
      os.path.basename(test_src)
    )
  ) == True, f"Should create symbol link of file ${os.path.basename(test_src)}\n in folder - ${test_target}"

  assert os.path.isfile(
    os.path.join(
      test_target,
      os.path.basename(test_src)
    )
  ) == True, f"Should be file"

  shutil.rmtree(test_target)
  os.remove(test_src)



if __name__ == "__main__":
  test_dir_path()
  test_file_path()