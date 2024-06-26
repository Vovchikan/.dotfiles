## Nix & Home Manager

### Установка Nix
#### через мои скрипты

1. Выполнить
```shell
.dotfiles/scripts/install_nix.sh
```
2. Перезагрузить активную сессию

#### По [Оф гайду](https://nix.dev/install-nix)

```shell
curl -L https://nixos.org/nix/install | sh -s -- --daemon
```

### Полезные ссылки по Nix

- [Поиск nix.packages](https://search.nixos.org/packages)
- [Скрипты через `nix-shell`](https://nix.dev/tutorials/first-steps/reproducible-scripts)
- очистка `$ nix-collect-garbage`
- [Синтаксис языка nix](https://nix.dev/tutorials/nix-language)

### Установка Home Manager по [Оф гайду](https://nix-community.github.io/home-manager/index.xhtml#ch-installation)

```shell
nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install
```

### Полезные ссылки по HM

- [Оф Readme](https://github.com/nix-community/home-manager?tab=readme-ov-file)
- [Документация по опциям из `home.nix`](https://nix-community.github.io/home-manager/options.xhtml)
- [Поиск опций](https://home-manager-options.extranix.com/)
- [Пример](https://github.com/mrjones2014/dotfiles/tree/master/home-manager) конфигурации