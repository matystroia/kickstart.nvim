---@type (LazyPluginSpec | string)[]
return {
  {
    'wakatime/vim-wakatime',
    lazy = false,
  },
  {
    'catgoose/nvim-colorizer.lua',
    event = 'BufReadPre',
    opts = {
      lazy_load = true,
      user_default_options = {
        names = false,
        rgb_fn = true,
        mode = 'virtualtext',
      },
    },
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
}
