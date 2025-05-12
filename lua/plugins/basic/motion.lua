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
      leap.opts.case_sensitive = false

      vim.keymap.set('n', 's', '<Plug>(leap-forward)')
      vim.keymap.set('n', 'S', '<Plug>(leap-backward)')

      vim.api.nvim_set_hl(0, 'LeapBackdrop', { link = 'Whitespace' })
    end,
  },
}
