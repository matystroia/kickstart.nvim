--- @type LazyPluginSpec[]
return {
  {
    'nvimtools/hydra.nvim',
    keys = {
      { '<C-w>\\', mode = 'n' },
    },
    config = function()
      local Hydra = require 'hydra'
      Hydra {
        config = {
          color = 'pink',
          hint = false,
          invoke_on_body = true,
          on_enter = function()
            vim.g.active_hydra = 'window'
          end,
          on_exit = function()
            vim.g.active_hydra = nil
          end,
        },
        mode = 'n',
        body = '<C-w>\\',
        heads = {
          {
            'h',
            function()
              require('custom.wince').resize('left', 5)
            end,
          },
          {
            'j',
            function()
              require('custom.wince').resize('down', 5)
            end,
          },
          {
            'k',
            function()
              require('custom.wince').resize('up', 5)
            end,
          },
          {
            'l',
            function()
              require('custom.wince').resize('right', 5)
            end,
          },
          { '<A-h>', '<C-w>H' },
          { '<A-j>', '<C-w>J' },
          { '<A-k>', '<C-w>K' },
          { '<A-l>', '<C-w>L' },
          { '<Esc>', nil, { exit = true } },
        },
      }
    end,
  },
  {
    'folke/which-key.nvim',
    keys = { '<Leader>' },
    opts = {
      delay = 750,
      icons = {
        mappings = false,
      },
      spec = {
        { '<Leader>c', group = '[C]ode', mode = { 'n', 'x' } },
        { '<Leader>d', group = '[D]ocument' },
        { '<Leader>r', group = '[R]ename' },
        { '<Leader>s', group = '[S]earch' },
        { '<Leader>w', group = '[W]orkspace' },
        { '<Leader>t', group = '[T]oggle' },
        { '<Leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      },
    },
  },
}
