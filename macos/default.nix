# macOS specific configurations.
{ catppuccinTheme }: {
  imports = [
    ./os-update-workaround.nix
    (import ./kitty.nix { inherit catppuccinTheme; })
  ];
}
