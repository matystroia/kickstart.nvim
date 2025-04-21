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
    'stevearc/oil.nvim',
    setup = function()
      ---@module 'oil'
      ---@type oil.SetupOpts
      require('oil').setup {
        use_default_keymaps = false,
        keymaps = {
          ['<CR>'] = { 'actions.select' },
          ['<BS>'] = { 'actions.parent', mode = 'n' },

          ['\\'] = { 'actions.select', opts = { vertical = true } },
          ['|'] = { 'actions.select', opts = { horizontal = true } },
          ['<C-t>'] = { 'actions.select', opts = { tab = true } },

          ['<C-v>'] = { 'actions.preview' },
          ['<C-r>'] = { 'actions.refresh' },

          ['.'] = { 'actions.cd', mode = 'n' },

          ['gs'] = { 'actions.change_sort', mode = 'n' },
          ['g.'] = { 'actions.toggle_hidden', mode = 'n' },
          ['g\\'] = { 'actions.toggle_trash', mode = 'n' },
        },
      }

      vim.keymap.set('n', '<Leader>o', function()
        require('oil').open_float()
      end, { desc = 'Open [O]il' })
    end,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    lazy = false,
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
