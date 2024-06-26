let
  more = { pkgs, ... }: {
    programs = {
      bat.enable = true;
    };
  };
in
[
  ./nvim
  ./tmux
  more
]
