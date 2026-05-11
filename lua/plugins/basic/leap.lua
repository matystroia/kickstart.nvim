---@type LazyPluginSpec
return {
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
}
