---@type PlugSpec
return {
  src = 'https://github.com/lukas-reineke/indent-blankline.nvim',
  setup = function()
    require('ibl').setup {
      indent = { char = '▏' },
      scope = { enabled = false },
    }
  end,
}
