---@type LazyPluginSpec
return {
  'chrisgrieser/nvim-spider',
  config = function()
    local spider = require 'spider'
    spider.setup { skipInsignificantPunctuation = false }
    vim.keymap.set({ 'n', 'x', 'o' }, '<M-w>', function()
      spider.motion 'w'
    end)
    vim.keymap.set({ 'n', 'x', 'o' }, '<M-e>', function()
      spider.motion 'e'
    end)
    vim.keymap.set({ 'n', 'x', 'o' }, '<M-b>', function()
      spider.motion 'b'
    end)
    vim.keymap.set('i', '<M-w>', '<C-o>d<M-b>', { remap = true })
  end,
}
