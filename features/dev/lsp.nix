{ config, lib, pkgs, ... }:
let
  cfg = config.features.dev.lsp;

  ls = lib.types.submodule {
    options = {
      name = lib.mkOption {
        type = lib.types.nonEmptyStr;

        description = "Language Server Name";
      };

      rootDirPattern = lib.mkOption {
        type = lib.types.nullOr lib.types.nonEmptyStr;

        default = null;
      };

      singleFileSupport = lib.mkOption {
        type = lib.types.bool;

        default = false;
      };
    };
  };

  lsToSetupStmt = c:
    let
      rootDir =
        if (c.rootDirPattern != null)
        then "root_dir = lspconfig.util.root_pattern('${c.rootDirPattern}'),"
        else "";
    in
    ''
      lspconfig.${c.name}.setup {
        ${rootDir}
        single_file_support = ${lib.trivial.boolToString c.singleFileSupport},
        capabilities = capabilities,
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
          name = "tsserver";
          rootDirPattern = "tsconfig.json";
        };
      };

      deno = lib.mkOption {
        type = ls;

        default = {
          name = "denols";
          rootDirPattern = "deno.json";
        };
      };

      css = lib.mkOption {
        type = ls;

        default = {
          name = "cssls";
          singleFileSupport = true;
        };
      };

      html = lib.mkOption {
        type = ls;

        default = {
          name = "html";
          singleFileSupport = true;
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
                  -- LSP key mappings
                  vim.api.nvim_create_autocmd("LspAttach", {
                    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
                    callback = function(ev)
                      local opts = { buffer = ev.buf }
                      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                    end,
                  })

                  -- Hover style
                  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
                    vim.lsp.handlers.hover,
                    {
                      border = "single",
                    }
                  )
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
                    behavior = cmp.ConfirmBehavior.Replace,
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
          {
            plugin = trouble-nvim;
            type = "lua";
            config = ''
              require("trouble").setup({
                icons = false,
                mode = "document_diagnostics",
                auto_open = true,
                auto_close = true,
                signs = {
                  error = "error",
                  warning = "warn",
                  hint = "hint",
                  information = "info"
                },
              })
            '';
          }
        ];
      };
    };
  };
}
