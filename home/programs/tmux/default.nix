{ lib, pkgs, vars, ... }:

let
  tmuxConf = lib.readFile ./default.conf;
in
{
  programs.tmux = {
    enable = true;
    prefix = "C-q";
    terminal = "screen-256color";
    historyLimit = 100000;
    plugins = with pkgs; [
      #tmuxPlugins.nord # Не работает без шрифта с поддержкой ligatures
      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = ''
        set -g @resurrect-strategy-vim 'session'
        set -g @resurrect-strategy-nvim 'session'
        set -g @resurrect-capture-pane-contents 'on'
        '';
      }
    ];
    extraConfig = tmuxConf;
  };
}
