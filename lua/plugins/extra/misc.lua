---@type (LazyPluginSpec | string)[]
return {
  {
    'wakatime/vim-wakatime',
    lazy = false,
  },
  {
    'catgoose/nvim-colorizer.lua',
    event = 'BufReadPre',
    config = function()
      local colorizer = require 'colorizer'
      colorizer.setup {
        lazy_load = true,
        user_default_options = {
          names = false,
          rgb_fn = true,
          RRGGBB = true,
          mode = 'virtualtext',
          virtualtext = '',
        },
      }

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('nvim-colorizer-lsp', { clear = true }),
        callback = function(event)
          if not vim.lsp.document_color.is_enabled(event.buf) then
            return
          end
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method 'textDocument/documentColor' then
            colorizer.detach_from_buffer(event.buf)
          end
        end,
      })
    end,
  },
  {
    'https://github.com/mbbill/undotree',
    cmd = 'UndoTreeShow',
  },
  -- TODO: Figure this out
  {
    'nvim-neorg/neorg',
    lazy = false,
    enabled = false,
    version = '*',
    config = function()
      require('neorg').setup {
        load = {
          ['core.defaults'] = {},
          ['core.concealer'] = {},
          ['core.dirman'] = {
            config = {
              workspaces = {
                notes = '~/notes',
              },
              default_workspace = 'notes',
            },
          },
        },
      }

      vim.wo.foldlevel = 99
      vim.wo.conceallevel = 2
    end,
  },
  { 'tpope/vim-eunuch' },
}
