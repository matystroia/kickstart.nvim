return {
  {
    'nvim-lualine/lualine.nvim',
    opts = {
      options = {
        theme = 'auto',
        section_separators = '',
        component_separators = '',
        refresh = {
          statusline = 100,
        },
      },
      sections = {
        lualine_a = {
          {
            function()
              local get_mode = require('lualine.utils.mode').get_mode
              return vim.g.active_hydra and vim.g.active_hydra:upper() or get_mode()
            end,
            color = function()
              return vim.g.active_hydra and 'ErrorMsg' or nil
            end,
            fmt = function(mode)
              return mode:sub(1, 1)
            end,
          },
        },
        lualine_b = {
          { 'branch', icons_enabled = false },
          { 'diff', symbols = { added = '', modified = '', removed = '' } },
        },
        lualine_c = {
          { 'filename' },
          { "require('custom.contextline').context()" },
        },
        lualine_x = { 'diagnostics' },
        lualine_y = {
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
          'filetype',
        },
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
