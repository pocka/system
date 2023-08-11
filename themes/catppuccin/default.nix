{ config, lib, pkgs, ... }:
let
  cfg = config.themes.catppuccin;
in
{
  options = {
    themes.catppuccin.flavor = lib.mkOption {
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

      home.packages = [
        # A generator for LS_COLORS with support for multiple color themes
        # https://github.com/sharkdp/vivid
        pkgs.vivid
      ];

      # Colourise exa, ls, lf, etc...
      # This needs to be done in .zshrc: in Crostini, `home.sessionVariables`
      # cannot invoke `vivid` binary. Probably evaluation timing?
      programs.zsh.initExtra = ''
        export LS_COLORS="$(vivid generate catppuccin-${cfg.flavor})"
      '';

      programs.bat = lib.mkIf config.programs.bat.enable {
        themes = {
          "catppuccin-${cfg.flavor}" = builtins.readFile (
            pkgs.fetchFromGitHub
              {
                owner = "catppuccin";
                repo = "bat";
                rev = "ba4d16880d63e656acced2b7d4e034e4a93f74b1";
                sha256 = "1g2r6j33f4zys853i1c5gnwcdbwb6xv5w6pazfdslxf69904lrg9";
              }
            + "/Catppuccin-${cfg.flavor}.tmTheme"
          );
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
                    lspIntegration = if config.features.dev.lsp.enable then "true" else "false";
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
          toFootHex = hex: lib.strings.removePrefix "#" hex;
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
