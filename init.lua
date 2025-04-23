vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.o.number = true
vim.o.relativenumber = true
vim.o.numberwidth = 3

vim.opt.mouse = ''
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

vim.opt.breakindent = true
vim.opt.undofile = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.signcolumn = 'yes'

vim.opt.updatetime = 750
vim.opt.timeoutlen = 300

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.formatoptions:remove { 'r', 'o' }
vim.opt.shortmess:append 'S'

vim.opt.wrap = false
vim.opt.cursorline = false
vim.opt.scrolloff = 5

vim.opt.confirm = false
vim.opt.termguicolors = true

-- TODO: Move these to commands.lua

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- DIE :)
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('local-fo', { clear = true }),
  callback = function()
    vim.opt_local.formatoptions:remove { 'r', 'o' }
  end,
})

-- Start terminal in insert mode
vim.api.nvim_create_autocmd('TermOpen', {
  group = vim.api.nvim_create_augroup('term-startinsert', { clear = true }),
  command = 'startinsert',
})

vim.api.nvim_create_user_command('Scratch', function(opts)
  local filetype = opts.fargs[1] or vim.bo.filetype or 'txt'

  local buf = vim.api.nvim_create_buf(true, true)
  vim.bo[buf].filetype = filetype

  -- Same directory so LSP doesn't spaz out
  local name = string.format('scratch-%03d.%s', math.random(0, 999), filetype)
  local path = vim.api.nvim_buf_get_name(0)
  vim.api.nvim_buf_set_name(buf, vim.fs.joinpath(path, name))

  -- Copy lines in range to new buffer
  if opts.range ~= 0 then
    local lines = vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)
  end

  -- Attach current LSP client if same filetype
  if opts.fargs[1] == nil or opts.fargs[1] == filetype then
    vim.iter(vim.lsp.get_clients { bufnr = vim.api.nvim_get_current_buf() }):each(function(client)
      vim.lsp.buf_attach_client(buf, client.id)
    end)
  end

  -- Replace save with format :)
  vim.keymap.set('n', '<Leader>w', '<Leader>f', { remap = true, buffer = buf })

  vim.api.nvim_set_current_buf(buf)
end, { nargs = '?', range = true, desc = 'Create scratch buffer' })

-- Terminal padding and background color
require('custom.terms').setup { 'wezterm' }
-- Polling WakaTime CLI
require('custom.wakatime').setup()

require 'keymap'
require 'plugins'
