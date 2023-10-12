# dotfiles

## Nix & Home Manager
All configs in `home.nix`.

Read this [example](https://github.com/mrjones2014/dotfiles/tree/master/home-manager).

Nix installation - [here](https://nixos.org/manual/nix/stable/installation/installing-binary).
```shell
$ curl -L https://nixos.org/nix/install | sh
```

Home Manager installation - [here](https://nix-community.github.io/home-manager/index.html)
```shell
$ nix-channel --add https://github.com/nix-community/home-manager/archive/release-23.05.tar.gz home-manager
$ nix-channel --update
$ nix-shell '<home-manager>' -A install

4 пункт я не понял для чего нужен, но я сделал так:
1. открыл `~/.profile`
2. добавил в конец `. "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"`
```

Home Manager config example - [here](https://github.com/mrjones2014/dotfiles/tree/master/home-manager)

After installation Nix & Home Manager:
```shell
$ ~/.dotfiles/scripts/links.sh
$ home-manager switch
```

### Neovim config
[Example](https://gist.github.com/nat-418/493d40b807132d2643a7058188bff1ca)

### Tmux config
[Example](https://haseebmajid.dev/posts/2023-07-10-setting-up-tmux-with-nix-home-manager/)
