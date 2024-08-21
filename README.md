# dotfiles

## Использования configure_scripts

### Создание символической ссылки
```shell
$ python3
>>> from configure_scripts.my_utils import link_path
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

---
## Примеры конфигов

### Neovim
[Example](https://gist.github.com/nat-418/493d40b807132d2643a7058188bff1ca)

### Tmux
[Readme](tmux/README.md)

### Zed
[Example](https://gist.github.com/kofta999/77fe78491830da3c7e252ceb2857e37c)
