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
    end,
  },
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    dependencies = {
      { 'github/copilot.vim' },
      { 'nvim-lua/plenary.nvim', branch = 'master' },
    },
    build = 'make tiktoken',
    config = function()
      require('CopilotChat').setup()
      vim.keymap.set('n', '<leader>cc', function()
        require('CopilotChat').open()
      end, { desc = 'Open Copilot Chat' })
    end,
  },
}
