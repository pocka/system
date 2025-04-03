{ config, lib, pkgs, ... }:
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

      rootDirPattern = lib.mkOption {
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

  lsToSetupStmt = c:
    let
      cmd =
        if (c.cmd != null)
        then "cmd = { ${builtins.concatStringsSep ", " (builtins.map (x: "\"${x}\"") c.cmd)} },"
        else "";
      rootDir =
        if (c.rootDirPattern != null)
        then "root_dir = lspconfig.util.root_pattern(${builtins.concatStringsSep ", " (builtins.map (x: "'${x}'") c.rootDirPattern)}),"
        else "";
      initOptions =
        if (c.initOptions != null)
        then "init_options = { ${c.initOptions} },"
        else "";
      settings =
        if (c.settings != null)
        then "settings = { ${c.settings} },"
        else "";
    in
    ''
      lspconfig.${c.name}.setup {
        ${cmd}
        ${rootDir}
        single_file_support = ${lib.trivial.boolToString c.singleFileSupport},
        capabilities = capabilities,
        ${initOptions}
        ${settings}
      }
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
          rootDirPattern = [ "tsconfig.json" ];
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
          rootDirPattern = [ "deno.json" "deno.jsonc" ];
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
          cmd = [ "zls" "--config-path" "${config.xdg.configHome}/zls.json" ];
          name = "zls";
        };
      };

      gleam = lib.mkOption {
        type = ls;

        default = {
          name = "gleam";
          # nvim-lspconfig incorrectly have ".git" in the default root_dir.
          rootDirPattern = [ "gleam.toml" ];
        };
      };
    };
  };

  config = {
    programs = lib.mkIf (config.features.dev.enable && cfg.enable) {
      neovim = lib.mkIf config.programs.neovim.enable {
        plugins = with pkgs.vimPlugins; [
          {
            plugin = cmp-nvim-lsp;
          }
          {
            plugin = nvim-lspconfig;
            type = "lua";

            config = builtins.concatStringsSep "\n" (
              [
                ''
                  -- Based on https://github.com/neovim/nvim-lspconfig#suggested-configuration

                  local capabilities = require("cmp_nvim_lsp").default_capabilities()
                  local lspconfig = require("lspconfig")

                ''
              ] ++
              (builtins.map lsToSetupStmt cfg.langs) ++
              [
                ''
                  -- [LSP]

                  vim.api.nvim_create_autocmd("LspAttach", {
                    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
                    callback = function(ev)
                      vim.keymap.set("n", "K", function()
                        vim.lsp.buf.hover({ border = "single" })
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
          {
            plugin = luasnip;
          }
          {
            plugin = nvim-cmp;
            type = "lua";
            config = ''
              local cmp = require("cmp")

              cmp.setup({
                -- cmp requires snippet engine, without the engine it crashes occasionally
                snippet = {
                  expand = function(args)
                    require("luasnip").lsp_expand(args.body)
                  end,
                },
                window = {
                  completion = cmp.config.window.bordered(),
                  documentation = cmp.config.window.bordered(),
                },
                mapping = cmp.mapping.preset.insert({
                  ["<CR>"] = cmp.mapping.confirm {
                    behavior = cmp.ConfirmBehavior.Insert,
                    select = true,
                  },
                  ["<Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                      cmp.select_next_item()
                      return
                    end

                    fallback()
                  end, { "i", "s" }),
                  ["<S-Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                      cmp.select_prev_item()
                      return
                    end

                    fallback()
                  end, { "i", "s" }),
                }),
                sources = {
                  { name = "nvim_lsp" }
                },
              })
            '';
          }
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

    home.packages = lib.mkIf (builtins.elem cfg.zig cfg.langs) [
      pkgs.zls
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
