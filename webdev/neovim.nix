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
          plugin = nvim-lspconfig;
          type = "lua";
          config = ''
            -- Based on https://github.com/neovim/nvim-lspconfig#suggested-configuration

            local lspconfig = require("lspconfig")

            -- Elm
            lspconfig.elmls.setup {}
            -- TypeScript
            lspconfig.tsserver.setup {
              root_dir = lspconfig.util.root_pattern("tsconfig.json"),
              single_file_support = false,
            }
            -- Deno
            lspconfig.denols.setup {
              root_dir = lspconfig.util.root_pattern("deno.json"),
            }
            -- CSS
            lspconfig.cssls.setup {}
            -- HTML
            lspconfig.html.setup {}

            -- LSP key mappings
            vim.api.nvim_create_autocmd("LspAttach", {
              group = vim.api.nvim_create_augroup("UserLspConfig", {}),
              callback = function(ev)
                local opts = { buffer = ev.buf }
                vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
              end,
            })
          '';
        }
      ];
    };
  };
}
