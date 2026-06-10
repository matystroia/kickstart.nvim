-- require 'custom.cmdwin_highlight'

vim.api.nvim_create_autocmd(vim.fn.has('nvim-0.13.0') == 1 and { 'TextYankPost', 'TextPutPost' } or 'TextYankPost', {
  desc = 'Highlight when yanking',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function(ev)
    if vim.fn.has('nvim-0.13.0') then
      local hl = ev.event == 'TextYankPost' and 'IncSearch' or 'DiffAdd'
      vim.hl.hl_op { higroup = hl }
    else
      vim.hl.on_yank()
    end
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  desc = 'Remove annoying formatopts',
  group = vim.api.nvim_create_augroup('local-fo', { clear = true }),
  callback = function() vim.opt_local.formatoptions:remove { 'r', 'o' } end,
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
    vim.keymap.set(
      'n',
      '<C-CR>',
      function() vim.api.nvim_exec2(vim.api.nvim_get_current_line(), {}) end,
      { buffer = true }
    )
  end,
})

vim.api.nvim_create_autocmd('User', {
  pattern = 'TSUpdate',
  callback = function()
    require('nvim-treesitter.parsers').difft = {
      install_info = {
        path = vim.fs.joinpath(vim.fn.stdpath 'config', 'assets/difft-parser'),
        queries = 'queries/difft',
      },
    }
    require('nvim-treesitter.parsers').gitlog = {
      install_info = {
        path = vim.fs.joinpath(vim.fn.stdpath 'config', 'assets/gitlog-parser'),
        queries = 'queries/gitlog',
      },
    }
  end,
})
