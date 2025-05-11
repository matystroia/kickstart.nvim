--- @type (LazyPluginSpec | string)[]
return {
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
          custom_areas = {
            right = function()
              local time = require('custom.wakatime').today()
              if time == nil then
                return { { text = '? ' } }
              end

              local ret = {}
              if time.hours then
                ret[#ret + 1] = string.format('%sh', time.hours)
              end
              if time.minutes then
                ret[#ret + 1] = string.format('%sm', time.hours)
              end

              return { { text = table.concat(ret, ' ') .. ' ' } }
            end,
          },
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
        theme = 'auto',
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
            fmt = function(mode)
              return mode:sub(1, 1)
            end,
          },
        },
        lualine_b = {
          { 'branch', icons_enabled = false },
          { 'diff', symbols = { added = '+', modified = '~', removed = '-' } },
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
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {
      indent = { char = '▏' },
      scope = { enabled = false },
    },
    enabled = true,
  },
  {
    'j-hui/fidget.nvim',
    config = function()
      local fidget = require 'fidget'
      local default_notification = vim.tbl_extend('force', fidget.notification.default_config, {
        icon = '',
        error_annote = '󰅚 ',
        warn_annote = '󰀪 ',
        info_annote = '󰋽 ',
        debug_annote = '󰌶 ',
      })

      fidget.setup {
        notification = {
          override_vim_notify = true,
          window = { border = 'rounded' },
          configs = { default = default_notification },
        },
      }
    end,
  },
}
