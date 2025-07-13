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

{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.themes.catppuccin;

  radius = 2;

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
      json = builtins.fromJSON (
        builtins.readFile (
          pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "palette";
            rev = "205dd54c6158b7648621cf9fd00e91f03888ce7e";
            sha256 = "y14fd8lvnG9hNY6CRU0JgxWouexEw91aIEMkr1NaM/4=";
          }
          + "/palette.json"
        )
      );

      flavor = json."${cfg.flavor}";

      stripSharp = hex: lib.strings.removePrefix "#" hex;

      darkFlavor = if cfg.flavor == "latte" then "mocha" else cfg.flavor;

      dark = json."${darkFlavor}";
      light = json.latte;
    in
    {
      features.wayland-de = lib.mkIf config.features.wayland-de.enable {
        niri = {
          background-color = "transparent";

          overview = {
            backdrop-color = flavor.base.hex;
          };

          layout = {
            focus-ring = {
              width = 1;
              active-color = flavor.overlay1.hex;
              inactive-color = flavor.surface1.hex;
            };

            border = {
              width = gap / 5;
              active-color = flavor.overlay2.hex;
              inactive-color = flavor.surface0.hex;
            };

            gaps = gap;

            struts.bottom = gap / -2;
          };

          window-rule-all = {
            corner-radius = radius;
          };
        };

        walker = {
          css = ''
            #window.dark {
              --background-color: ${flavor.base.hex};
              --surface-background-color: ${flavor.surface0.hex};
              --border-color: ${flavor.lavender.hex};
              --foreground-color: ${flavor.text.hex};
              --dimmed-foreground-color: ${flavor.subtext0.hex};
            }

            #window.light {
              --background-color: ${json.latte.base.hex};
              --surface-background-color: ${json.latte.surface0.hex};
              --border-color: ${json.latte.lavender.hex};
              --foreground-color: ${json.latte.text.hex};
              --dimmed-foreground-color: ${json.latte.subtext0.hex};
            }
          '';
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
      };

      xdg.configFile =
        let
          baseStyle = ''
            * {
              font-family: Roboto, Helvetica, Arial, sans-serif;
              font-size: 16px;
            }

            window#waybar {
              font-weight: bold;
            }

            .module {
              padding: 2px 4px;
              margin: 4px;

              border-radius: 3px;
            }

            #clock,
            #network,
            #pulseaudio,
            #tray {
              color: inherit;
            }
          '';
        in
        {
          "waybar/style-light.css".text = ''
            ${baseStyle}

            window#waybar {
              background-color: ${light.base.hex};
              color: ${light.text.hex};
            }

            #tray {
              background-color: ${light.sapphire.hex};
            }

            #pulseaudio:hover {
              background-color: ${light.surface0.hex};
            }
          '';

          "waybar/style-dark.css".text = ''
            ${baseStyle}

            window#waybar {
              background-color: ${dark.base.hex};
              color: ${dark.text.hex};
            }

            #tray {
              background-color: transparent;
            }

            #pulseaudio:hover {
              background-color: ${dark.surface0.hex};
            }
          '';
        };

      programs.ghostty =
        let
          darkFlavor = if cfg.flavor == "latte" then "mocha" else cfg.flavor;
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
