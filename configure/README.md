# CONFIGURE SCRIPTS

## Примеры использования

### Создание символической ссылки

```shell
$ python3
>>> from configure.my_utils import link_path
>>> import os
>>>
>>> src = os.path.expanduser("~/.dotfiles/zed/keymap.json")
>>> target_folder = os.path.expanduser("~/.config/zed")
>>> backup_dir = os.path.expanduser("~/.backup")
>>>
>>> link_path(src, target_folder, backup_dir)

    Make symbolic link for keymap.json
    in /home/svv/.config/zed

Move to backup -  /home/svv/.backup/keymap.json.backup
```

`link_path` принимает только абсолютные пути, поэтому приходится преобразовывать
каждый путь с помощью `os.path.expanduser`.