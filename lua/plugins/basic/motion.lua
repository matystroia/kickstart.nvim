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
    url = 'https://codeberg.org/andyg/leap.nvim',
    lazy = false,
    dependencies = { 'tpope/vim-repeat' },
    config = function()
      local leap = require 'leap'
      leap.opts.vim_opts['go.ignorecase'] = false

      vim.keymap.set('n', 'z', '<Plug>(leap-forward)')
      vim.keymap.set('n', 'Z', '<Plug>(leap-backward)')

      vim.api.nvim_set_hl(0, 'LeapBackdrop', { link = 'Whitespace' })
    end,
  },
  {
    'chrisgrieser/nvim-spider',
    config = function()
      local spider = require 'spider'
      spider.setup { skipInsignificantPunctuation = false }
      vim.keymap.set({ 'n', 'x', 'o' }, '<M-w>', function()
        spider.motion 'w'
      end)
      vim.keymap.set({ 'n', 'x', 'o' }, '<M-e>', function()
        spider.motion 'e'
      end)
      vim.keymap.set({ 'n', 'x', 'o' }, '<M-b>', function()
        spider.motion 'b'
      end)
      vim.keymap.set('i', '<M-w>', '<C-o>d<M-b>', { remap = true })
    end,
  },
}
