-- TODO: Look at all mini.nvim plugins

---@type PlugSpec
return {
  src = 'https://github.com/nvim-mini/mini.surround',
  setup = function()
    require('mini.surround').setup {
      mappings = {
        add = '<A-s>a',
        delete = '<A-s>d',
        find = '<A-s>f',
        find_left = '<A-s>F',
        highlight = '<A-s>h',
        replace = '<A-s>r',
      },
      n_lines = 500,
    }
  end,
}
