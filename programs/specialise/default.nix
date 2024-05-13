{ pkgs }:
pkgs.buildGoModule {
  name = "specialise";

  src = ./.;

  vendorHash = null;

  ldflags = [
    "-X main.homeManagerPath=${pkgs.home-manager}/bin/home-manager"
  ];
}
