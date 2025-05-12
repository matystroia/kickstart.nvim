vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  desc = 'Remove annoying formatopts',
  group = vim.api.nvim_create_augroup('local-fo', { clear = true }),
  callback = function()
    vim.opt_local.formatoptions:remove { 'r', 'o' }
  end,
})

vim.api.nvim_create_autocmd('TermOpen', {
  desc = 'Start terminal in insert mode',
  group = vim.api.nvim_create_augroup('term-startinsert', { clear = true }),
  command = 'startinsert',
})

vim.api.nvim_create_autocmd('CmdwinEnter', {
  desc = '<C-CR> in command window to run without closing',
  group = vim.api.nvim_create_augroup('cmdwin-keep-open', { clear = true }),
  callback = function()
    vim.keymap.set('n', '<C-CR>', function()
      vim.api.nvim_exec2(vim.api.nvim_get_current_line(), {})
    end, { buffer = true })
  end,
})
