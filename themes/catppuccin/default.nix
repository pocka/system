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

{ config, lib, pkgs, ... }:
let
  cfg = config.themes.catppuccin;

  radius = 6;

  gap = 16;
in
{
  options = {
    themes.catppuccin = {
      flavor = lib.mkOption {
        type = lib.types.enum [
          "latte"
          "frappe"
          "macchiato"
          "mocha"
        ];

        default = "mocha";

        description = ''
          Specify which Catppuccin _flavor_ (color palette) to use.
        '';
      };
    };
  };

  config =
    let
      json = builtins.fromJSON (builtins.readFile (
        pkgs.fetchFromGitHub
          {
            owner = "catppuccin";
            repo = "palette";
            rev = "205dd54c6158b7648621cf9fd00e91f03888ce7e";
            sha256 = "y14fd8lvnG9hNY6CRU0JgxWouexEw91aIEMkr1NaM/4=";
          }
        + "/palette.json"
      ));

      flavor = json."${cfg.flavor}";

      stripSharp = hex: lib.strings.removePrefix "#" hex;
    in
    {
      features.wayland-de = lib.mkIf config.features.wayland-de.enable {
        niri = {
          background-color = flavor.mantle.hex;

          layout = {
            focus-ring = {
              width = gap / 4;
              active-color = flavor.peach.hex;
              inactive-color = flavor.surface0.hex;
            };

            gaps = gap;

            struts.bottom = gap / -2;
          };

          window-rule-all = {
            corner-radius = radius;
          };
        };

        swaylock = {
          flags = [
            "color=${stripSharp flavor.base.hex}"
            "indicator-thickness=8"
            "indicator-idle-visible"
            "inside-color=${stripSharp flavor.base.hex}"
            "inside-clear-color=${stripSharp flavor.base.hex}"
            "inside-ver-color=${stripSharp flavor.base.hex}"
            "inside-wrong-color=${stripSharp flavor.base.hex}"
            "key-hl-color=${stripSharp flavor.mauve.hex}"
            "line-color=${stripSharp flavor.surface0.hex}"
            "line-clear-color=${stripSharp flavor.surface0.hex}"
            "line-ver-color=${stripSharp flavor.overlay2.hex}"
            "line-wrong-color=${stripSharp flavor.red.hex}"
            "ring-color=${stripSharp flavor.base.hex}"
            "ring-clear-color=${stripSharp flavor.base.hex}"
            "ring-ver-color=${stripSharp flavor.overlay0.hex}"
            "ring-wrong-color=${stripSharp flavor.maroon.hex}"
            "text-color=${stripSharp flavor.text.hex}"
            "text-clear-color=${stripSharp flavor.text.hex}"
            "text-ver-color=${stripSharp flavor.subtext1.hex}"
            "text-wrong-color=${stripSharp flavor.red.hex}"
          ];
        };

        tofi = rec {
          fuzzyMatch = false;

          font = {
            family = "Dank Mono";
            size = 11;
          };

          scale = true;

          anchor = "bottom";
          horizontal = true;

          # "100%" does not work on fractional scaling display
          # https://github.com/philj56/tofi/issues/79
          width = 0;

          height = font.size + padding.top + padding.bottom + selection.backgroundPadding.top + selection.backgroundPadding.bottom + border.width * 2;
          resultSpacing = 10 + selection.backgroundPadding.left + selection.backgroundPadding.right;

          # Avoid unwanted clipping
          # https://github.com/philj56/tofi/issues/65#issuecomment-1335556041
          clipToPadding = false;

          padding = {
            top = 6;
            right = 8;
            # There is no way to specify line-height: need to adjust padding-bottom or something.
            bottom = 5;
            left = 8;
          };

          prompt = {
            text = ">";
            background = "#00000000";
            color = flavor.teal.hex;
            padding = 8;
          };

          input = {
            color = flavor.subtext0.hex;
            backgroundPadding = {
              top = 0;
              right = 32;
              bottom = 0;
              left = 0;
            };
          };

          selection = {
            background = flavor.surface2.hex + "66";
            color = flavor.text.hex;
            matchColor = flavor.peach.hex;

            backgroundPadding = {
              top = 4;
              right = 8;
              bottom = 4;
              left = 8;
            };
            backgroundCornerRadius = 4;
          };

          textColor = flavor.text.hex;
          backgroundColor = flavor.mantle.hex;

          outline = {
            width = 0;
            color = "#00000000";
          };

          border = {
            width = 0;
            color = "#00000000";
          };
        };
      };

      services.dunst = lib.mkIf config.services.dunst.enable {
        settings = {
          global = {
            width = 400;
            height = 300;
            offset = "4x4";
            padding = 4;
            horizontal_padding = 8;
            frame_width = 2;
            gap_size = 6;
            font = "Monospace 10";
            corner_radius = 2;
          };

          urgency_low = {
            background = flavor.base.hex;
            foreground = flavor.subtext0.hex;
            frame_color = flavor.overlay1.hex;
          };

          urgency_normal = {
            background = flavor.base.hex;
            foreground = flavor.text.hex;
            frame_color = flavor.blue.hex;
          };

          urgency_critical = {
            background = flavor.base.hex;
            foreground = flavor.text.hex;
            frame_color = flavor.yellow.hex;
          };
        };
      };

      programs.waybar = lib.mkIf config.programs.waybar.enable {
        settings = {
          main = {
            position = "bottom";
          };
        };

        style = ''
          * {
            font-family: "FontAwesome", Roboto, Helvetica, Arial, sans-serif;
            font-size: 16px;
          }

          window#waybar {
            padding: ${builtins.toString gap}px;

            background-color: transparent;
            color: ${flavor.text.hex};
          }

          .modules-left,
          .modules-right {
            margin: 4px;
          }

          #workspaces button {
            font-size: 12px;
            padding: 0px 2px;

            background-color: transparent;
            border-radius: 2px;;
            color: ${flavor.overlay1.hex};
          }

          #workspaces button:hover {
            text-decoration: underline;
          }

          #workspaces button.focused {
            font-weight: bold;
            background-color: rgba(${flavor.surface2.raw}, 0.4);
            color: ${flavor.text.hex};
          }

          #workspaces button.urgent {
            color: ${flavor.yellow.hex};
          }

          #clock,
          #network,
          #pulseaudio,
          #tray {
            padding: 0px 6px;

            color: inherit;
          }

          #pulseaudio:hover {
            background-color: rgba(${flavor.surface2.raw}, 0.4);
          }
        '';
      };

      programs.ghostty =
        let
          darkFlavor =
            if cfg.flavor == "latte" then
              "mocha"
            else
              cfg.flavor;
        in
        {
          settings = {
            theme = "light:catppuccin-latte-corrected,dark:catppuccin-${darkFlavor}";
          };

          themes.catppuccin-latte-corrected = {
            palette = [
              "0=${json.latte.crust.hex}"
              "1=${json.latte.red.hex}"
              "2=${json.latte.green.hex}"
              "3=${json.latte.yellow.hex}"
              "4=${json.latte.blue.hex}"
              "5=${json.latte.pink.hex}"
              "6=${json.latte.teal.hex}"
              "7=${json.latte.subtext0.hex}"
              "8=${json.latte.surface2.hex}"
              "9=#de293e"
              "10=#49af3d"
              "11=#eea02d"
              "12=#456eff"
              "13=#fe85d8"
              "14=#2d9fa8"
              "15=${json.latte.text.hex}"
            ];
            background = stripSharp json.latte.base.hex;
            foreground = stripSharp json.latte.text.hex;
            cursor-color = stripSharp json.latte.rosewater.hex;
            selection-background = stripSharp json.latte.surface2.hex;
            selection-foreground = stripSharp json.latte.text.hex;
          };
        };
    };
}
