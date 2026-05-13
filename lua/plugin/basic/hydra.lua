---@type PlugSpec
return {
  src = 'https://github.com/nvimtools/hydra.nvim',
  setup = function()
    local hydra = require 'hydra'
    local wince = require 'custom.wince'
    hydra {
      config = {
        color = 'pink',
        hint = false,
        invoke_on_body = true,
        on_enter = function() vim.g.active_hydra = 'window' end,
        on_exit = function() vim.g.active_hydra = nil end,
      },
      mode = 'n',
      body = '<C-w>\\',
      heads = {
        {
          'h',
          function() wince.resize('left', 5) end,
        },
        {
          'j',
          function() wince.resize('down', 5) end,
        },
        {
          'k',
          function() wince.resize('up', 5) end,
        },
        {
          'l',
          function() wince.resize('right', 5) end,
        },
        { '<A-h>', '<C-w>H' },
        { '<A-j>', '<C-w>J' },
        { '<A-k>', '<C-w>K' },
        { '<A-l>', '<C-w>L' },
        { '<Esc>', nil, { exit = true } },
      },
    }
  end,
}
