--- @type LazyPluginSpec[]
return {
  {
    'anuvyklack/hydra.nvim',
    config = function()
      -- TODO: window, git
      local hydra = require 'hydra'
      hydra {
        name = 'Window',
        config = {
          invoke_on_body = true,
          hint = { boder = 'rounded' },
        },
        mode = 'n',
        body = '<Leader>o',
        heads = {
          { 'h', '<Cmd>resize -5<CR>' },
          { 'j', '<Cmd>vertical resize +5<CR>' },
          { 'k', '<Cmd>vertical resize -5<CR>' },
          { 'l', '<Cmd>resize +5<CR>' },
          { '<Esc>', nil, { exit = true, desc = false } },
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
