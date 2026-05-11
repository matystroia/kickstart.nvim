---@type (LazyPluginSpec | string)[]
return {
  {
    'wakatime/vim-wakatime',
    lazy = false,
    version = '11.3.0',
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
    end,
  },
  {
    'https://github.com/mbbill/undotree',
    cmd = 'UndotreeShow',
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
