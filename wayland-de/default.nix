# Wayland Desktop Environment
{ catppuccinTheme }: { ... }: {
  # I'm not sure this changes behaviour in a meaningful way.
  targets.genericLinux = {
    enable = true;
  };

  # Update ~/.profile too.
  # https://github.com/nix-community/home-manager/issues/1439
  programs.bash = {
    enable = true;
  };

  imports = [
    (
      import ./foot.nix {
        inherit catppuccinTheme;
      }
    )
  ];
}
