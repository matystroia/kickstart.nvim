vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.o.number = true
vim.o.relativenumber = true
vim.o.numberwidth = 3

vim.o.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

vim.o.breakindent = true
vim.o.autoindent = true
vim.o.smartindent = true

vim.o.undofile = true

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.signcolumn = 'yes'

vim.o.updatetime = 500
vim.o.timeoutlen = 500
vim.o.splitright = true
vim.o.splitbelow = true

vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true

vim.opt.shortmess:append 'S'

vim.o.wrap = false
vim.o.cursorline = false
vim.o.scrolloff = 5

vim.o.confirm = false
vim.o.termguicolors = true

vim.o.winborder = 'rounded'

-- Define project local config in .nvim.lua
vim.o.exrc = true

if not vim.g.neovide and not vim.g.started_by_firenvim then
  require('vim._extui').enable {}
end

require 'autocmd'
require 'usercmd'
require 'keymap'
require 'plugins'
