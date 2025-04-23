--- @type LazyPluginSpec[]
return {
  {
    'nvimtools/hydra.nvim',
    keys = {
      { '<C-w><C-r>', mode = 'n' },
    },
    config = function()
      -- TODO: git?
      local Hydra = require 'hydra'
      local cmd = require('hydra.keymap-util').cmd

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
        body = '<C-w><C-r>',
        heads = {
          { 'h', cmd 'vertical resize -5' },
          { 'j', cmd 'resize +5' },
          { 'k', cmd 'resize -5' },
          { 'l', cmd 'vertical resize +5' },
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
