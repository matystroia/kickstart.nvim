--- @type PlugSpec
return {
  src = 'https://github.com/akinsho/bufferline.nvim',
  deps = {
    { src = 'https://github.com/nvim-tree/nvim-web-devicons' },
  },
  setup = function()
    require('bufferline').setup {
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
            if time.hours > 0 then
              ret[#ret + 1] = string.format('%sh', time.hours)
            end
            if time.minutes > 0 then
              ret[#ret + 1] = string.format('%sm', time.minutes)
            end

            return { { text = table.concat(ret, ' ') .. ' ' } }
          end,
        },
      },
    }

    vim.keymap.set('n', '<Tab>g', '<Cmd>BufferLinePick<CR>')
    vim.keymap.set('n', '<Tab>D', '<Cmd>BufferLinePickClose<CR>')
    vim.keymap.set('n', '<Tab>o', '<Cmd>BufferLineCloseOthers<CR>')

    vim.api.nvim_exec_autocmds('User', { pattern = 'Bufferline' })
  end,
}
