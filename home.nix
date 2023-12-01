{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "vbuser";
  home.homeDirectory = "/home/vbuser";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.htop
    pkgs.xclip
    pkgs.keepassxc
    pkgs.screen

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/vbuser/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  imports = [
    ./home_manager_modules/tmux.nix
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.git = {
    package = pkgs.gitAndTools.gitFull;
    enable = true;
    userName = "Vladimir Samorodov";
    userEmail = "vovchikan@gmail.com";
    aliases = {
      s = "status";
      newbranch = "checkout -b";
      fixup = "commit --amend --no-edit";
      lol = "log --oneline";
      lol3 = "lol -3";
      lol5 = "lol -5";
    };
    extraConfig = {
      core = {
        editor = "nvim";
        excludesFile = "~/.gitignore";
      };
      rebase = {
        autoSquash = true;
        abbreviateCommands = true;
      };
      rerere = {
        enabled = true;
      };
      pull = {
        rebase = false;
      };
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraLuaConfig = /* lua */ ''
      local map = vim.api.nvim_set_keymap

      function im(key, command)
        map('i', key, command, {noremap = true})
      end

      vim.o.termguicolors=true
      vim.o.mouse=a                 -- Enable your mouse

      vim.o.tabstop       = 2 -- How many columns of whitespace a \t is worth.
      vim.o.shiftwidth    = 2 -- Is how many columns of whitespace a 'level of indentation' is worth.
      vim.o.softtabstop   = 2 -- How many columns of whitespace a tab keypress or a backspace keypress is worth.
      vim.o.expandtab     = true -- use spaces instead of tabs (\t).
      vim.o.scrolloff     = 8 -- set number of screen lines to keep above/below the cursor
      vim.o.showtabline   = 2 -- Always show tabs (default 1)

      -- Indent: https://neovim.io/doc/user/indent.html
      vim.o.smartindent=true        -- Makes indenting smart
      vim.o.autoindent=true         -- uses the indent from the previous line

      -- Number of lines: https://neovim.io/doc/user/vim.oions.html#'number'
      vim.o.number=true             -- Line numbers
      vim.o.relativenumber=true			-- Set displayed number to be relative to the cursor

      -- Keys
      im('jk', '<Esc>')
      im('kj', '<Esc>')
    '';
  };
}
