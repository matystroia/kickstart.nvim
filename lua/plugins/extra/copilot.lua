---@type (LazyPluginSpec | string)[]
return {
  {
    'github/copilot.vim',
    config = function()
      vim.keymap.set('i', '<C-y>', 'copilot#Accept("")', {
        expr = true,
        replace_keycodes = false,
      })
      vim.g.copilot_no_tab_map = true

      -- FIXME: Should use treesitter context when available
      vim.api.nvim_create_autocmd('InsertEnter', {
        group = vim.api.nvim_create_augroup('copilot-comments', { clear = true }),
        desc = 'Smecheri fut fraeri comenteaza nene cu multa stima si respect',
        callback = function()
          if vim.bo.commentstring == '' then
            return
          end
          -- Remove `%s` and escape all punctuation
          local pattern = '^%s*' .. vim.bo.commentstring:gsub('%%s', ''):gsub('(%p)', '%%%0')
          vim.b.copilot_enabled = not vim.api.nvim_get_current_line():match(pattern)
        end,
      })
    end,
  },
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    dependencies = {
      { 'github/copilot.vim' },
      { 'nvim-lua/plenary.nvim', branch = 'master' },
    },
    opts = {},
    keys = {
      {
        '<leader>cc',
        function()
          require('CopilotChat').open()
        end,
        desc = 'Open Copilot Chat',
      },
    },
    build = 'make tiktoken',
  },
}
