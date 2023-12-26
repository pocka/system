{ config, lib, pkgs, ... }:
let
  cfg = config.themes.catppuccin;
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

      wallpaperWidth = lib.mkOption {
        type = lib.types.ints.unsigned;
        default = 3840;
      };

      wallpaperHeight = lib.mkOption {
        type = lib.types.ints.unsigned;
        default = 2160;
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

      wallpaper = import ./wallpaper {
        inherit pkgs;
        flavor = cfg.flavor;
        colors = flavor;
        mocha = json.mocha;
        width = cfg.wallpaperWidth;
        height = cfg.wallpaperHeight;
      };
    in
    {
      features.basics.zsh.theme =
        let
          zshFg = hex: "%F{${hex}}";
        in
        {
          text = zshFg flavor.text.hex;
          vi.insert = zshFg flavor.blue.hex;
          vi.normal = zshFg flavor.green.hex;
          vcs.info = zshFg flavor.subtext0.hex;
          vcs.staged = zshFg flavor.green.hex;
          vcs.unstaged = zshFg flavor.red.hex;
          symbol = zshFg flavor.overlay0.hex;
        };

      # Only a subset of configurable knobs... Nushell's docs and API stability is unbelievably bad.
      features.data.nushell = lib.mkIf (config.features.data.enable && config.programs.nushell.enable) {
        colorConfig = {
          separator = flavor.subtext1.hex;
          leading_trailing_space_bg = flavor.mantle.hex;
          header = flavor.green.hex;
          row_index = flavor.pink.hex;
          hints = flavor.subtext0.hex;

          date = flavor.maroon.hex;
          string = flavor.text.hex;
          bool = flavor.peach.hex;
          int = flavor.peach.hex;
          float = flavor.peach.hex;

          shape_bool = flavor.peach.hex;
          shape_string = flavor.green.hex;
          shape_int = flavor.peach.hex;
          shape_float = flavor.peach.hex;
        };
      };

      features.wayland-de = lib.mkIf config.features.wayland-de.enable {
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

        swaybg = {
          background = flavor.base.hex;
          image = "${wallpaper}/usr/share/backgrounds/catppuccin-${cfg.flavor}.png";
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

      home.packages = [
        # A generator for LS_COLORS with support for multiple color themes
        # https://github.com/sharkdp/vivid
        pkgs.vivid

        (lib.mkIf config.features.wayland-de.enable wallpaper)
      ];

      wayland.windowManager.sway = lib.mkIf config.wayland.windowManager.sway.enable {
        config = {
          colors = {
            focused = {
              childBorder = flavor.lavender.hex;
              background = flavor.base.hex;
              text = flavor.text.hex;
              indicator = flavor.rosewater.hex;
              border = flavor.lavender.hex;
            };
            focusedInactive = {
              childBorder = flavor.overlay0.hex;
              background = flavor.base.hex;
              text = flavor.overlay1.hex;
              indicator = flavor.rosewater.hex;
              border = flavor.overlay0.hex;
            };
            unfocused = {
              childBorder = flavor.overlay0.hex;
              background = flavor.base.hex;
              text = flavor.overlay1.hex;
              indicator = flavor.rosewater.hex;
              border = flavor.overlay0.hex;
            };
            urgent = {
              childBorder = flavor.peach.hex;
              background = flavor.base.hex;
              text = flavor.peach.hex;
              indicator = flavor.overlay0.hex;
              border = flavor.peach.hex;
            };
            placeholder = {
              childBorder = flavor.overlay0.hex;
              background = flavor.base.hex;
              text = flavor.text.hex;
              indicator = flavor.overlay0.hex;
              border = flavor.overlay0.hex;
            };
            background = flavor.base.hex;
          };

          gaps = {
            outer = 6;
            inner = 6;

            smartBorders = "on";
            smartGaps = true;
          };

          window = {
            border = 1;
            titlebar = false;

            hideEdgeBorders = "smart";
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
            font-size: 14px;
          }

          window#waybar {
            border-top: 1px solid ${flavor.overlay0.hex};

            background-color: ${flavor.mantle.hex};
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

      # Colourise eza, ls, lf, etc...
      # This needs to be done in .zshrc: in Crostini, `home.sessionVariables`
      # cannot invoke `vivid` binary. Probably evaluation timing?
      programs.zsh.initExtra = ''
        export LS_COLORS="$(vivid generate catppuccin-${cfg.flavor})"
      '';

      programs.bat = lib.mkIf config.programs.bat.enable {
        themes = {
          "catppuccin-${cfg.flavor}" = {
            src = pkgs.fetchFromGitHub {
              owner = "catppuccin";
              repo = "bat";
              rev = "ba4d16880d63e656acced2b7d4e034e4a93f74b1";
              sha256 = "1g2r6j33f4zys853i1c5gnwcdbwb6xv5w6pazfdslxf69904lrg9";
            };

            file = "Catppuccin-${cfg.flavor}.tmTheme";
          };
        };

        config = {
          theme = "catppuccin-${cfg.flavor}";
        };
      };

      programs.tmux.plugins = [
        {
          plugin = pkgs.tmuxPlugins.catppuccin;
          extraConfig = ''
            set -g @plugin 'catppuccin/tmux'
            set -g @catppuccin_flavour '${cfg.flavor}'
            set -g @catppuccin_no_patched_fonts_theme_enabled on
          '';
        }
      ];

      programs.neovim =
        {
          plugins =
            [
              {
                plugin = pkgs.vimPlugins.catppuccin-nvim;
                type = "lua";
                config =
                  let
                    lspIntegration = lib.trivial.boolToString config.features.dev.lsp.enable;
                  in
                  ''
                    vim.o.termguicolors = true

                    require("catppuccin").setup({
                      flavour = "${cfg.flavor}",
                      transparent_background = true,
                      integrations = {
                        indent_blankline = {
                          enabled = true,
                        },
                        cmp = ${lspIntegration},
                        lsp_trouble = ${lspIntegration},
                      },
                    })

                    vim.cmd.colorscheme "catppuccin"
                  '';
              }
            ];
        };

      programs.kitty =
        let
          # Convert the input string's first character to upper case.
          # Example: "foo" -> "Foo"
          toCapital = with lib;
            str:
            let
              len = builtins.stringLength str;
              head = strings.toUpper (builtins.substring 0 1 str);
              tail = builtins.substring 1 (len - 1) str;
            in
            head + tail;
        in
        {
          theme = "Catppuccin-${toCapital cfg.flavor}";
        };

      programs.foot =
        let
          toFootHex = lib.strings.removePrefix "#";
          fg = toFootHex flavor.surface0.hex;
          bg = toFootHex flavor.text.hex;
        in
        {
          settings.main = {
            include = "${config.xdg.configHome}/foot/theme.conf";
          };

          settings.cursor = {
            # Foot by default invert fg/bg for cursor. However, this makes
            # cursor on indent_blankline's indent char/spaces barely visible.
            color = "${fg} ${bg}";
          };
        };

      xdg.configFile."foot/theme.conf" = lib.mkIf config.programs.foot.enable {
        text = builtins.readFile (
          pkgs.fetchFromGitHub
            {
              owner = "catppuccin";
              repo = "foot";
              rev = "009cd57bd3491c65bb718a269951719f94224eb7";
              sha256 = "0f0r8d4rn54gibrzfhiy4yr8bi7c8j18ggp1y9lyidc1dmy9kvw0";
            }
          + "/catppuccin-${cfg.flavor}.conf"
        );
      };
    };
}
