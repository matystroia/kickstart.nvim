vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.o.number = true
vim.o.relativenumber = true
vim.o.numberwidth = 3

vim.o.mouse = ''
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

vim.api.nvim_create_user_command('GitHubUrl', function(opts)
  local remote = vim.fn.FugitiveRemote()
  if remote.host ~= 'github.com' then
    return vim.notify('Not a GitHub repo', vim.log.levels.ERROR)
  end

  local remote_path = remote.path:gsub('%.git$', '')
  local head = vim.fn.FugitiveHead()

  local file_path = vim.fn.FugitivePath()
  local relative_path = file_path:gsub('^' .. vim.fn.FugitiveWorkTree() .. '/', '')

  local lines = ''
  if opts.range ~= 0 then
    lines = '#L' .. opts.line1 .. '-L' .. opts.line2
  end

  -- TODO: Absolute commit path
  local url = string.format('https://github.com/%s/blob/%s/%s%s', remote_path, head, relative_path, lines)

  vim.fn.setreg('+', url)
  vim.print 'Copied to clipboard'
end, { range = true, desc = 'Get GitHub URL' })

-- Terminal padding and background color
require('custom.terms').setup { 'wezterm' }

-- Polling WakaTime CLI
require('custom.wakatime').setup()

-- Context line
require('custom.contextline').setup()

require 'autocmd'
require 'keymap'
require 'plugins'

-- Workspace config
local workspace_config = vim.fs.joinpath(vim.uv.cwd(), '.nvim.lua')
local stat = vim.uv.fs_stat(workspace_config)
if stat and stat.type == 'file' then
  dofile(workspace_config)
end
