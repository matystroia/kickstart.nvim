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
            local session = vim.v.this_session:match '.+/(.+)%.vim$'
            return { { text = session }, { text = ' ' .. require('custom.wakatime').today_display() .. ' ' } }
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
