--- @type LazyPluginSpec[]
return {
  {
    'sainnhe/gruvbox-material',
    priority = 1000,
    config = function()
      vim.g.gruvbox_material_enable_italic = true
      vim.g.gruvbox_material_background = 'light'
      vim.cmd.colorscheme 'gruvbox-material'
    end,
  },
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },
  {
    'akinsho/bufferline.nvim',
    config = function()
      local bufferline = require 'bufferline'
      bufferline.setup {
        options = {
          show_buffer_close_icons = false,
          show_close_icon = false,
        },
      }
    end,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
  },
  {
    'echasnovski/mini.nvim',
    config = function()
      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = true }

      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end
    end,
  },
}
