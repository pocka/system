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

{ glib, pkg-config, stdenvNoCC, installShellFiles, zig }:
stdenvNoCC.mkDerivation rec {
  pname = "my-theme";
  version = "1.0.0";

  buildInputs = [ glib ];
  nativeBuildInputs = [ pkg-config zig.hook installShellFiles ];

  src = ./.;

  meta = {
    mainProgram = ",theme";
  };

  postInstall = ''
    installShellCompletion --zsh --cmd ${pname} <(cat << "EOF"
    #compdef ${meta.mainProgram}

    function _${pname} {
      local line state

      _arguments -C \
        "1: :->variant"

      case "$state" in
        (variant)
          _values "variant" \
            "system" \
            "dark" \
            "light"
        ;;
      esac
    }

    if [ "$funcstack[1]" = "_${pname}" ]; then
      _${pname} "$@"
    else
      compdef _${pname} "${meta.mainProgram}"
    fi
    EOF)
  '';
}
