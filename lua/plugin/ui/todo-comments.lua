---@type PlugSpec
return {
  src = 'https://github.com/folke/todo-comments.nvim',
  deps = {
    { src = 'https://github.com/nvim-lua/plenary.nvim' },
  },
  setup = function()
    require('todo-comments').setup { signs = false }
  end,
}
