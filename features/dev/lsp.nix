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
  cfg = config.features.dev.lsp;

  ls = lib.types.submodule {
    options = {
      cmd = lib.mkOption {
        type = lib.types.nullOr (lib.types.listOf lib.types.nonEmptyStr);

        description = "Launch command";

        default = null;
      };

      name = lib.mkOption {
        type = lib.types.nonEmptyStr;

        description = "Language Server Name";
      };

      rootMarkers = lib.mkOption {
        type = lib.types.nullOr (lib.types.listOf lib.types.nonEmptyStr);

        default = null;
      };

      singleFileSupport = lib.mkOption {
        type = lib.types.bool;

        default = false;
      };

      initOptions = lib.mkOption {
        type = lib.types.nullOr lib.types.nonEmptyStr;

        default = null;
      };

      settings = lib.mkOption {
        type = lib.types.nullOr lib.types.nonEmptyStr;

        default = null;
      };
    };
  };

  lsToSetupStmt =
    c:
    let
      cmd =
        if (c.cmd != null) then
          "cmd = { ${builtins.concatStringsSep ", " (builtins.map (x: "\"${x}\"") c.cmd)} },"
        else
          "";
      rootMarkers =
        if (c.rootMarkers != null) then
          "root_markers = { ${
            builtins.concatStringsSep ", " (builtins.map (x: "'${x}'") c.rootMarkers)
          } },"
        else
          "";
      initOptions =
        if (c.initOptions != null) then "init_options = { ${c.initOptions} }," else "";
      settings = if (c.settings != null) then "settings = { ${c.settings} }," else "";
    in
    ''
      vim.lsp.config('${c.name}', {
        ${cmd}
        ${rootMarkers}
        workspace_required = ${lib.trivial.boolToString (!c.singleFileSupport)},
        ${initOptions}
        ${settings}
        capabilities = {
          textDocument = {
            completion = {
              completionItem = {
                snippetSupport = false,
              }
            }
          }
        }
      })
      vim.lsp.enable('${c.name}')
    '';
in
{
  options = {
    features.dev.lsp = {
      enable = lib.mkEnableOption "LSP";

      langs = lib.mkOption {
        type = lib.types.listOf ls;

        default = [ ];
      };

      elm = lib.mkOption {
        type = ls;

        default = {
          name = "elmls";
        };
      };

      typescript = lib.mkOption {
        type = ls;

        default = {
          name = "ts_ls";
          rootMarkers = [ "tsconfig.json" ];
          initOptions = ''
            preferences = {
              includePackageJsonAutoImports = "off",
              jsxAttributeCompletionStyle = "none",
              autoImportFileExcludePatterns = { "**" },
            }
          '';
        };
      };

      deno = lib.mkOption {
        type = ls;

        default = {
          name = "denols";
          rootMarkers = [
            "deno.json"
            "deno.jsonc"
          ];
          settings = ''
            deno = {
              suggest = {
                autoImports = false,
              }
            }
          '';
        };
      };

      go = lib.mkOption {
        type = ls;

        default = {
          name = "gopls";
        };
      };

      css = lib.mkOption {
        type = ls;

        default = {
          name = "cssls";
          singleFileSupport = true;
          initOptions = ''
            provideFormatter = false
          '';
          settings = ''
            css = {
              validate = false
            }
          '';
        };
      };

      html = lib.mkOption {
        type = ls;

        default = {
          name = "html";
          singleFileSupport = true;
        };
      };

      zig = lib.mkOption {
        type = ls;

        default = {
          cmd = [
            "zls"
            "--config-path"
            "${config.xdg.configHome}/zls.json"
          ];
          name = "zls";
        };
      };

      gleam = lib.mkOption {
        type = ls;

        default = {
          name = "gleam";
          # nvim-lspconfig incorrectly have ".git" in the default root_markers.
          rootMarkers = [ "gleam.toml" ];
        };
      };

      swift = lib.mkOption {
        type = ls;

        default = {
          name = "sourcekit";
        };
      };
    };
  };

  config = {
    programs = lib.mkIf (config.features.dev.enable && cfg.enable) {
      neovim = lib.mkIf config.programs.neovim.enable {
        plugins = with pkgs.vimPlugins; [
          {
            plugin = mini-completion;
            type = "lua";
            config = ''
              require("mini.completion").setup({
                window = {
                  info = { border = "single" },
                  signature = { border = "single" },
                },
                lsp_completion = {
                  snippet_insert  = vim.snippet.expand,
                },
                fallback_action = function()
                end,
              })

              -- from :h mini-completion
              local imap_expr = function(lhs, rhs)
                vim.keymap.set("i", lhs, rhs, { expr = true })
              end
              imap_expr("<Tab>", [[pumvisible() ? "\<C-n>" : "\<Tab>"]])
              imap_expr("<S-Tab>", [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]])

              local keycode = vim.keycode or function(x)
                return vim.api.nvim_replace_termcodes(x, true, true, true)
              end
              local keys = {
                ['cr']        = keycode('<CR>'),
                ['ctrl-y']    = keycode('<C-y>'),
                ['ctrl-y_cr'] = keycode('<C-y><CR>'),
              }

              _G.cr_action = function()
                if vim.fn.pumvisible() ~= 0 then
                  -- If popup is visible, confirm selected item or add new line otherwise
                  local item_selected = vim.fn.complete_info()['selected'] ~= -1
                  return item_selected and keys['ctrl-y'] or keys['ctrl-y_cr']
                else
                  -- If popup is not visible, use plain `<CR>`. You might want to customize
                  -- according to other plugins. For example, to use 'mini.pairs', replace
                  -- next line with `return require('mini.pairs').cr()`
                  return keys['cr']
                end
              end

              vim.keymap.set('i', '<CR>', 'v:lua._G.cr_action()', { expr = true })
            '';
          }
          {
            plugin = nvim-lspconfig;
            type = "lua";

            config = builtins.concatStringsSep "\n" (
              [
                ''
                  -- Based on https://github.com/neovim/nvim-lspconfig#suggested-configuration

                  local lspconfig = require("lspconfig")

                ''
              ]
              ++ (builtins.map lsToSetupStmt cfg.langs)
              ++ [
                ''
                  -- [LSP]

                  vim.api.nvim_create_autocmd("LspAttach", {
                    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
                    callback = function(ev)
                      vim.keymap.set("n", "K", function()
                        vim.lsp.buf.hover({ border = "rounded" })
                      end, { buffer = ev.buf })
                    end,
                  })

                  -- Rename
                  -- <https://neovim.io/doc/user/lsp.html#vim.lsp.buf.rename()>
                  vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, {})

                  -- Highlight a token under a cursor
                  -- <https://neovim.io/doc/user/lsp.html#vim.lsp.buf.document_highlight()>
                  vim.keymap.set("n", "<leader>lh", function()
                    -- Previous highlights need to be manually cleared.
                    vim.lsp.buf.clear_references()
                    vim.lsp.buf.document_highlight()
                  end, {})

                  -- Go to definition
                  -- <https://neovim.io/doc/user/lsp.html#vim.lsp.buf.definition()>
                  vim.keymap.set("n", "<leader>ld", vim.lsp.buf.definition, {})

                  -- Clear LSP highlights
                  -- <https://neovim.io/doc/user/lsp.html#vim.lsp.buf.clear_references()>
                  vim.keymap.set("n", "<leader>lc", vim.lsp.buf.clear_references, {})
                ''
              ]
            );
          }
          { plugin = luasnip; }
        ];
      };

      helix = lib.mkIf config.programs.helix.enable {
        settings = {
          editor = {
            lsp = {
              snippets = false;
            };
          };
        };

        languages = {
          language = [
            {
              name = "typescript";
              roots = [ "tsconfig.json" ];
            }
          ];
        };
      };
    };

    home.packages = [
      (lib.mkIf (builtins.elem cfg.zig cfg.langs) pkgs.zls)
      (lib.mkIf (!pkgs.stdenv.isDarwin) pkgs.sourcekit-lsp)
    ];

    # zls, the Zig Language Server does not support LSP's initializationOptions
    # but their own zig.json.
    xdg.configFile."zls.json" = {
      enable = builtins.elem cfg.zig cfg.langs;

      text = builtins.toJSON {
        enable_snippets = false;
        enable_argument_placeholders = false;
      };
    };
  };
}
