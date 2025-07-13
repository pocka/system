# Copyright 2025 Shota FUJI <pockawoooh@gmail.com>
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

{
  pkgs,
  installShellFiles,
  lib,
  buildGoModule,
}:
buildGoModule rec {
  name = "hm-clean";

  src = ./.;

  nativeBuildInputs = [ installShellFiles ];

  vendorHash = null;

  ldflags = [ "-X main.homeManagerPath=${pkgs.home-manager}/bin/home-manager" ];

  postInstall = ''
    installShellCompletion --zsh --cmd ${name} <(cat << "EOF"
    #compdef ${name}

    function _${name} {
      local line state

      _arguments -C \
        "--help[Output usage text to stdout]" \
        "--verbose[Enable verbose logging]"
    }

    if [ "$funcstack[1]" = "_${name}" ]; then
      _${name} "$@"
    else
      compdef _${name} ${name}
    fi
    EOF)
  '';
}
