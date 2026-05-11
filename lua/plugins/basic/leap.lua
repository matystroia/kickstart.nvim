---@type PlugSpec
return {
  src = 'https://codeberg.org/andyg/leap.nvim',
  deps = {
    { src = 'https://github.com/tpope/vim-repeat' },
  },
  setup = function()
    local leap = require 'leap'
    leap.opts.vim_opts['go.ignorecase'] = false

    vim.keymap.set('n', 'z', '<Plug>(leap-forward)')
    vim.keymap.set('n', 'Z', '<Plug>(leap-backward)')

    vim.api.nvim_set_hl(0, 'LeapBackdrop', { link = 'Whitespace' })
  end,
}
