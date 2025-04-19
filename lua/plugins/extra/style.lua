--- @type (LazyPluginSpec | string)[]
return {
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('tokyonight').setup()
      vim.cmd.colorscheme 'tokyonight'
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

      vim.keymap.set('n', '<Tab>g', '<Cmd>BufferLinePick<CR>')
      vim.keymap.set('n', '<Tab>D', '<Cmd>BufferLinePickClose<CR>')
      vim.keymap.set('n', '<Tab>o', '<Cmd>BufferLineCloseOthers<CR>')
    end,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
  },
  {
    'nvim-lualine/lualine.nvim',
    opts = {
      options = {
        theme = 'tokyonight',
        section_separators = '',
        component_separators = '',
      },
      sections = {
        lualine_a = {
          {
            function()
              local get_mode = require('lualine.utils.mode').get_mode
              return vim.g.active_hydra and vim.g.active_hydra:upper() or get_mode()
            end,
            color = function()
              return vim.g.active_hydra and 'Foo' or nil
            end,
          },
        },
        lualine_b = {
          { 'branch', icons_enabled = false },
          { 'diff', symbols = { added = '+', modified = '~', removed = '-' } },
        },
        lualine_c = {
          'filename',
          {
            function()
              if vim.v.hlsearch == 0 then
                return ''
              end

              local ok, result = pcall(vim.fn.searchcount)
              if not ok or next(result) == nil then
                return ''
              end

              local denominator = math.min(result.total, result.maxcount)
              return string.format('%d/%d', result.current, denominator)
            end,
            color = 'IncSearch',
          },
        },
        lualine_x = {
          {
            function()
              local time = require('wakatime').today()
              if time == nil then
                return '-'
              end

              local ret = {}
              if time.hours then
                table.insert(ret, string.format('%sh', time.hours))
              end
              if time.minutes then
                table.insert(ret, string.format('%sm', time.minutes))
              end

              return table.concat(ret, ' ')
            end,
          },
          'diagnostics',
        },
        lualine_y = { 'filetype' },
        lualine_z = { 'location' },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },
      extensions = { 'oil', 'fugitive' },
    },
    dependencies = { 'nvim-tree/nvim-web-devicons' },
  },
}
