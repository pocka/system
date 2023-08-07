# Shell for using home-manager & Flakes without installing/configuring.
# Based on:
# https://github.com/Misterio77/nix-config/blob/68939a161c97bb875fb1ead17c172c36de24bd01/shell.nix
{
  pkgs ? let
    lock =
      (
        builtins.fromJSON (builtins.readFile ./flake.lock)
      )
      .nodes
      .nixpkgs
      .locked;

    # Pin nixpkgs, so the shell can be invoked without channels
    nixpkgs = fetchTarball {
      url = "https://github.com/${lock.owner}/${lock.repo}/archive/${lock.rev}.tar.gz";
      sha256 = lock.narHash;
    };
  in
    import nixpkgs {overlays = [];},
  ...
}: {
  default = pkgs.mkShell {
    shellHook = ''
      export NIX_CONFIG="experimental-features = nix-command flakes"
    '';

    nativeBuildInputs = with pkgs; [
      nix
      home-manager
    ];
  };
}
