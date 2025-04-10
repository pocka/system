# Copyright 2023 Shota FUJI <pockawoooh@gmail.com>
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
# REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
# INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
# LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.
#
# SPDX-License-Identifier: 0BSD
#
# ===
# Shell for using home-manager & Flakes without installing/configuring.
# Based on:
# https://github.com/Misterio77/nix-config/blob/68939a161c97bb875fb1ead17c172c36de24bd01/shell.nix

{ pkgs ? let
    lock =
      (
        builtins.fromJSON (builtins.readFile ./flake.lock)
      ).nodes.nixpkgs.locked;

    # Pin nixpkgs, so the shell can be invoked without channels
    nixpkgs = fetchTarball {
      url = "https://github.com/${lock.owner}/${lock.repo}/archive/${lock.rev}.tar.gz";
      sha256 = lock.narHash;
    };
  in
  import nixpkgs { overlays = [ ]; }
, ...
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
