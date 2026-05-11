---@type LazyPluginSpec
return {
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
}
