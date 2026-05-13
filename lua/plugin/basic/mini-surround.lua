-- TODO: Look at all mini.nvim plugins

---@type PlugSpec
return {
  src = 'https://github.com/nvim-mini/mini.surround',
  setup = function()
    require('mini.surround').setup { n_lines = 500 }
  end,
}
