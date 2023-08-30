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
```

After installation Nix & Home Manager:
```shell
$ ~/.dotfiles/scripts/links.sh
$ home-manager switch
```
