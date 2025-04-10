-- Set <space> as the leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.have_nerd_font = true

-- Hyprland LSP
vim.filetype.add {
  pattern = { ['.*/hypr/.*%.conf'] = 'hyprlang' },
}

-- [[ Setting options ]]

-- Make line numbers default
vim.opt.number = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 1500

-- Decrease mapped sequence wait time
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Expand tab to 4 spaces
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- Show which line your cursor is on
vim.opt.cursorline = false

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
vim.opt.confirm = false

vim.opt.termguicolors = true

-- [[ Basic Keymaps ]]

vim.keymap.set('n', '<C-s>', ':w<CR>')
vim.keymap.set('i', '<C-s>', '<C-o>:w<CR>')

vim.keymap.set('n', '<leader>w', '<cmd>wq<CR>', { desc = 'Save and quit' })
vim.keymap.set('n', '<leader>q', '<cmd>qa!<CR>', { desc = 'Quit without saving' })
vim.keymap.set('n', '<leader>a', 'ggVG', { desc = 'Select all' })

vim.keymap.set('i', '<A-BS>', '<C-w>', { remap = true })

vim.keymap.set('n', '<C-w>', '<cmd>q<CR>', { desc = 'Quit', nowait = true })
vim.keymap.set('n', '<C-n>', '<cmd>nohls<CR>', { desc = 'Clear search' })

vim.opt.wrap = false
vim.keymap.set('n', '<leader>z', '<cmd>set wrap!<CR>', { desc = 'Toggle line wrap' })

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus left' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus right' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus up' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus down' })

-- Indent with <Alt-h> and <Alt-l>
vim.keymap.set('n', '<A-h>', '<<')
vim.keymap.set('n', '<A-l>', '>>')
vim.keymap.set('v', '<A-h>', '<gv')
vim.keymap.set('v', '<A-l>', '>gv')

-- Move with <Alt-j> and <Alt-k>
-- [:m(ove)] [.|'<|'>] [n]
vim.keymap.set('n', '<A-j>', ':m+1<CR>')
vim.keymap.set('v', '<A-k>', ":m'<-2<CR>gv")
vim.keymap.set('n', '<A-k>', ':m-2<CR>')
vim.keymap.set('v', '<A-j>', ":m'>+1<CR>gv")

-- Move in insert mode
vim.keymap.set('i', '<C-h>', '<Left>')
vim.keymap.set('i', '<C-l>', '<Right>')

vim.keymap.set({ 'n', 'v' }, '<leader>/', function()
  return vim.api.nvim_get_mode().mode == 'n' and 'gcc' or 'gc'
end, { expr = true, remap = true, desc = 'Toggle comment' })

-- [[ Basic Autocommands ]]

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- [[ Install `lazy.nvim` plugin manager ]]

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ Minimal plugins in firenvim ]]

local firenvim_whitelist = {
  'sainnhe/gruvbox-material',
  'echasnovski/mini.nvim',
  'nvim-treesitter/nvim-treesitter',
  'jinh0/eyeliner.nvim',
  'glacambre/firenvim',
}

local function cond_firenvim(plugin)
  local plugin_name = plugin[1]
  for _, whitelisted_plugin in pairs(firenvim_whitelist) do
    if plugin_name == whitelisted_plugin then
      return true
    end
  end
  return false
end

require 'plugins'

-- vim: ts=2 sts=2 sw=2 et
