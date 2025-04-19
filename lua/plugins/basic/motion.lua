--- @type (LazyPluginSpec | string)[]
return {
  {
    'jinh0/eyeliner.nvim',
    config = function()
      local eyeliner = require 'eyeliner'
      eyeliner.setup {
        highlight_on_key = true,
        dim = true,
      }
    end,
  },
  {
    'ggandor/leap.nvim',
    config = function()
      local leap = require 'leap'
      leap.opts.case_sensitive = true
      vim.keymap.set('n', 's', '<Plug>(leap-forward)')
      vim.keymap.set('n', 'S', '<Plug>(leap-backward)')
    end,
  },
  {
    'rhysd/clever-f.vim',
    init = function()
      vim.g.clever_f_across_no_line = 1
      vim.g.clever_f_not_overwrites_standard_mappings = 1
    end,
    enabled = false,
  },
}
