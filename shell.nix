# Copyright 2023 Shota FUJI <pockawoooh@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0
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
