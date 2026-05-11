---@type PlugSpec
return {
  src = 'https://github.com/windwp/nvim-autopairs',
  setup = function()
    require('nvim-autopairs').setup {}
  end,
}
