return {
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
}
