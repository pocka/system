# Language specific tools are not configured in this file because
# these tools are project specific. Each project should have Flake
# file (provided by the project or manually created by a user).
{
  config,
  pkgs,
  ...
}: {
  programs = {
    neovim = {
      plugins = with pkgs.vimPlugins; [
        {
          plugin = cmp-nvim-lsp;
        }
        {
          plugin = nvim-lspconfig;
          type = "lua";
          config = ''
            -- Based on https://github.com/neovim/nvim-lspconfig#suggested-configuration

            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            local lspconfig = require("lspconfig")

            -- Elm
            lspconfig.elmls.setup {
              capabilities = capabilities,
            }
            -- TypeScript
            lspconfig.tsserver.setup {
              root_dir = lspconfig.util.root_pattern("tsconfig.json"),
              single_file_support = false,
              capabilities = capabilities,
            }
            -- Deno
            lspconfig.denols.setup {
              root_dir = lspconfig.util.root_pattern("deno.json"),
              capabilities = capabilities,
            }
            -- CSS
            lspconfig.cssls.setup {
              capabilities = capabilities,
            }
            -- HTML
            lspconfig.html.setup {
              capabilities = capabilities,
            }

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
          '';
        }
        {
          plugin = nvim-cmp;
          type = "lua";
          config = ''
            local cmp = require("cmp")

            cmp.setup({
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
}
