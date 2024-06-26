# dotfiles

## Nix & Home Manager

### Установка пакетного менеджера Nix для текущего пользователя

[Оф гайд](https://nix.dev/install-nix)
```shell
curl -L https://nixos.org/nix/install | sh -s -- --daemon

# Проверка установленной версии
nix --version
```

- [Поиск nix.packages](https://search.nixos.org/packages)
- [Скрипты через `nix-shell`](https://nix.dev/tutorials/first-steps/reproducible-scripts)
  - очистка `$ nix-collect-garbage`
- [Синтаксис языка nix](https://nix.dev/tutorials/nix-language)

### Установка Home Manager

- [Оф гайд](https://nix-community.github.io/home-manager/index.xhtml#ch-installation)
- [Оф Readme](https://github.com/nix-community/home-manager?tab=readme-ov-file)
```shell
nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install
```

- [Документация по опциям из `home.nix`](https://nix-community.github.io/home-manager/options.xhtml)
- [Поиск опций](https://home-manager-options.extranix.com/)

#### 4 пункт я не понял для чего нужен, но я сделал так:
1. открыл `~/.profile`
2. добавил в конец `. "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"`


[Пример](https://github.com/mrjones2014/dotfiles/tree/master/home-manager) конфигурации.

### После установки **Nix** и **Home Manager**:
```shell
$ ~/.dotfiles/scripts/links.py
$ home-manager switch
```

### Neovim config
[Example](https://gist.github.com/nat-418/493d40b807132d2643a7058188bff1ca)

### Tmux config
[Example](https://haseebmajid.dev/posts/2023-07-10-setting-up-tmux-with-nix-home-manager/)
