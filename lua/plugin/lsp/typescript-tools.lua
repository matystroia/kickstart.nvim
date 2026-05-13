---@type PlugSpec
return {
  src = 'https://github.com/pmizio/typescript-tools.nvim',
  deps = {
    { src = 'https://github.com/nvim-lua/plenary.nvim' },
  },
  setup = function()
    require('typescript-tools').setup {}
  end,
}
