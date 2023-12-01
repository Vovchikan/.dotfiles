{ pkgs, vars, ... }:

{
  programs.tmux = {
    enable = true;
    prefix = "C-q";
    terminal = "tmux-256color";
    historyLimit = 100000;
    extraConfig = ''
      # Create windows and panes in same dir
      bind c new-window      -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      bind '"' split-window -v -c "#{pane_current_path}"

      # Move window
      bind-key S-Left swap-window -t -1
      bind-key S-Right swap-window -t +1

      # vi selection
      set-window-option -g mode-keys vi
      bind-key -T copy-mode-vi 'v' send-keys -X begin-selection
      bind-key -T copy-mode-vi 'y' send-keys -X copy-selection-and-cancel
      bind-key p paste-buffe
      bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "xclip -se c -i"

    '';
  };
}
