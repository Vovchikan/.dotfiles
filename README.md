# dotfiles

## Nix & Home Manager

### Установка пакетного менеджера Nix для текущего пользователя

```shell
.dotfiles/scripts/install_nix.sh
```

### Установка Home Manager

- [Оф гайд](https://nix-community.github.io/home-manager/index.xhtml#ch-installation)
- [Оф Readme](https://github.com/nix-community/home-manager?tab=readme-ov-file)
```shell
nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install
```

### После установки **Nix** и **Home Manager**:

!!! Обязательно поменяй home.stateVersion в `.dotfiles/home/home.nix` перед линковкой
```
  home.stateVersion = "23.05"; # Please read the comment before changing.
```

```shell
$ ~/.dotfiles/scripts/links.py
$ home-manager switch
```

### Neovim config
[Example](https://gist.github.com/nat-418/493d40b807132d2643a7058188bff1ca)

### Tmux config
[Example](https://haseebmajid.dev/posts/2023-07-10-setting-up-tmux-with-nix-home-manager/)
