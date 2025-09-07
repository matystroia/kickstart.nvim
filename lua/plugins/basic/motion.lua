--- @type (LazyPluginSpec | string)[]
return {
  {
    'jinh0/eyeliner.nvim',
    config = function()
      local eyeliner = require 'eyeliner'
      eyeliner.setup {
        default_keymaps = false,
        highlight_on_key = true,
        dim = true,
      }
    end,
  },
  {
    'ggandor/leap.nvim',
    lazy = false,
    dependencies = { 'tpope/vim-repeat' },
    config = function()
      local leap = require 'leap'
      leap.opts.case_sensitive = true

      vim.keymap.set('n', 'z', '<Plug>(leap-forward)')
      vim.keymap.set('n', 'Z', '<Plug>(leap-backward)')

      vim.api.nvim_set_hl(0, 'LeapBackdrop', { link = 'Whitespace' })
    end,
  },
  {
    'chrisgrieser/nvim-spider',
    keys = {
      {
        '<Leader><Leader>w',
        function()
          require('spider').motion 'w'
        end,
        mode = { 'n', 'x', 'o' },
      },
      {
        '<Leader><Leader>e',
        function()
          require('spider').motion 'e'
        end,
        mode = { 'n', 'x', 'o' },
      },
      {
        '<Leader><Leader>b',
        function()
          require('spider').motion 'b'
        end,
        mode = { 'n', 'x', 'o' },
      },
    },
  },
}
