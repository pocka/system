# Essential modules: every machine should include this module.
# Should covers everything from admin task to daily usages.
# Other modules assumes this is included.
{ catppuccinTheme }:
{ ... }: {
  xdg = { enable = true; };

  imports = [
    (
      import ./tools.nix {
        inherit catppuccinTheme;
      }
    )
    (
      import ./neovim.nix {
        inherit catppuccinTheme;
      }
    )
    (
      import ./tmux.nix {
        inherit catppuccinTheme;
      }
    )
    ./zsh.nix
  ];
}

