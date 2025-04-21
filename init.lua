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

-- TODO: Move these to commands.lua

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_user_command('Scratch', function(opts)
  local filetype = opts.fargs[1] or vim.bo.filetype

  local buf = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_buf_set_name(buf, filetype ~= '' and 'scratch.' .. filetype or 'scratch')

  local bufopts = { filetype = filetype }
  for key, value in pairs(bufopts) do
    vim.api.nvim_set_option_value(key, value, { buf = buf })
  end

  -- Copy lines in range to new buffer
  if opts.range ~= 0 then
    local lines = vim.api.nvim_buf_get_lines(0, opts.line1, opts.line2, false)
    vim.api.nvim_buf_set_lines(buf, 0, 0, false, lines)
  end

  -- Attach current LSP client if creating same filetype
  if opts.fargs[1] == nil then
    local clients = vim.lsp.get_clients { bufnr = vim.api.nvim_get_current_buf() }
    for _, client in ipairs(clients) do
      if client.name ~= 'GitHub Copilot' then
        vim.lsp.buf_attach_client(buf, client.id)
      end
    end
  end

  vim.api.nvim_set_current_buf(buf)
end, { nargs = '?', range = true, desc = 'Create scratch buffer' })

-- Terminal padding and background color
require('terms').setup { 'wezterm' }
-- Polling WakaTime CLI
require('wakatime').setup()

require 'keymap'
require 'plugins'
