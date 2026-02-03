return {
  {
    'stevearc/oil.nvim',
    config = function()
      require('oil').setup {
        use_default_keymaps = false,
        delete_to_trash = true,
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
        float = {
          max_width = 0.6,
          max_height = 0.6,
        },
      }
      vim.keymap.set('n', '<Leader>O', function()
        require('oil').open()
      end)
      vim.keymap.set('n', '<Leader>o', function()
        require('oil').open_float()
      end)
    end,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    lazy = false,
  },
}
