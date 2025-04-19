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

vim.opt.formatoptions:remove 'r'
vim.opt.shortmess:append 'S'

vim.opt.wrap = false
vim.opt.cursorline = false
vim.opt.scrolloff = 5

vim.opt.confirm = false
vim.opt.termguicolors = true

-- Set autochdir when started with file as argument
vim.api.nvim_create_autocmd('VimEnter', {
  desc = 'Auto autochdir',
  group = vim.api.nvim_create_augroup('auto-autochdir', { clear = true }),
  callback = function()
    if vim.g.started_by_firenvim then
      return
    end
    if #vim.v.argv ~= 3 then
      return
    end

    local stat = vim.uv.fs_stat(vim.v.argv[3])
    if stat and stat.type == 'file' then
      vim.opt.autochdir = true
    end
  end,
})

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Terminal padding and background color
require('terms').setup { 'wezterm', 'alacritty' }

require 'keymap'
require 'plugins'
