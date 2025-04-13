vim.keymap.set('n', '<Leader>q', '<Cmd>q<CR>')
vim.keymap.set('n', '<Leader>w', '<Cmd>silent w<CR>')

vim.keymap.set('n', '<Leader>a', 'ggVG')
vim.keymap.set('n', '<Leader>z', '<Cmd>set wrap!<CR>')

vim.keymap.set('n', '<Leader>bo', function()
  local this_buf = vim.api.nvim_get_current_buf()
  for buf in
    vim.iter(vim.api.nvim_list_bufs()):filter(function(buf)
      return vim.api.nvim_buf_is_loaded(buf) and buf ~= this_buf
    end)
  do
    vim.cmd.bdelete { buf, bang = true }
  end
end)

vim.keymap.set('i', '<A-BS>', '<C-w>', { remap = true })
vim.keymap.set('n', '<C-n>', '<Cmd>nohls<CR>')

-- Move between windows
vim.keymap.set('n', '<C-h>', '<C-w><C-h>')
vim.keymap.set('n', '<C-l>', '<C-w><C-l>')
vim.keymap.set('n', '<C-j>', '<C-w><C-j>')
vim.keymap.set('n', '<C-k>', '<C-w><C-k>')

-- Move window
vim.keymap.set('n', '<C-w>h', '<C-w>H')
vim.keymap.set('n', '<C-w>l', '<C-w>L')
vim.keymap.set('n', '<C-w>j', '<C-w>J')
vim.keymap.set('n', '<C-w>k', '<C-w>K')

-- Resize window
-- TODO: Hydra
-- vim.keymap.set('n', '<C-w>H', '<Cmd>vertical resize -5<CR>')
-- vim.keymap.set('n', '<C-w>L', '<Cmd>vertical resize +5<CR>')
-- vim.keymap.set('n', '<C-w>J', '<Cmd>resize +5<CR>')
-- vim.keymap.set('n', '<C-w>K', '<Cmd>resize -5<CR>')

local function cmd_hist(cmd)
  return function()
    vim.cmd(cmd)
    vim.fn.histadd('cmd', cmd)
  end
end

vim.keymap.set('n', '<C-w>H', cmd_hist 'resize -5')
vim.keymap.set('n', '<C-w>L', cmd_hist 'resize +5')
vim.keymap.set('n', '<C-w>J', cmd_hist 'resize +5')
vim.keymap.set('n', '<C-w>K', cmd_hist 'resize -5')

-- Indent with <Alt-h> and <Alt-l>
vim.keymap.set('n', '<A-h>', '<<')
vim.keymap.set('n', '<A-l>', '>>')
vim.keymap.set('v', '<A-h>', '<gv')
vim.keymap.set('v', '<A-l>', '>gv')

-- Move with <Alt-j> and <Alt-k>
vim.keymap.set('n', '<A-j>', ':m+1<CR>')
vim.keymap.set('n', '<A-k>', ':m-2<CR>')
vim.keymap.set('v', '<A-j>', ":m'>+1<CR>gv")
vim.keymap.set('v', '<A-k>', ":m'<-2<CR>gv")

vim.keymap.set('n', 'g;', '@:', { desc = 'Repeat Ex' })

-- Move in insert and command mode
vim.keymap.set({ 'i', 'c' }, '<A-h>', '<Left>')
vim.keymap.set({ 'i', 'c' }, '<A-l>', '<Right>')

vim.keymap.set({ 'n', 'v' }, '<Leader>/', function()
  return vim.api.nvim_get_mode().mode == 'n' and 'gcc' or 'gc'
end, { expr = true, remap = true, desc = 'Toggle comment' })

vim.api.nvim_create_autocmd('CmdwinEnter', {
  callback = function()
    vim.keymap.set('n', '<C-CR>', '<CR>q:', { buffer = true })
  end,
  group = vim.api.nvim_create_augroup('cmdwin-keep-open', { clear = true }),
})
