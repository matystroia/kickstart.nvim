vim.keymap.set('n', '<Leader>q', '<Cmd>q<CR>')
vim.keymap.set('n', '<Leader>Q', '<Cmd>q!<CR>')
vim.keymap.set('n', '<Leader>w', '<Cmd>silent w<CR>')

-- Buffers
vim.keymap.set('n', '<Tab>n', '<Cmd>bn<CR>')
vim.keymap.set('n', '<Tab>p', '<Cmd>bp<CR>')
vim.keymap.set('n', '<Right>', '<Cmd>bn<CR>')
vim.keymap.set('n', '<Left>', '<Cmd>bp<CR>')
vim.keymap.set('n', '<Tab>d', function()
  local buf = vim.api.nvim_win_get_buf(0)

  local alt_bufs = vim.iter(vim.api.nvim_list_bufs()):filter(function(b)
    return b ~= buf and vim.api.nvim_buf_is_loaded(b) and vim.bo[b].buflisted
  end)

  local alt_buf = alt_bufs:next()
  if alt_buf ~= nil then
    local closest_buf = alt_bufs:fold({ math.abs(alt_buf - buf), alt_buf }, function(acc, b)
      local dif = math.abs(b - buf)
      return dif < acc[1] and { dif, b } or acc
    end)[2]
    vim.api.nvim_win_set_buf(0, closest_buf)
  else
    vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(true, true))
  end

  vim.api.nvim_buf_delete(buf, { force = true })
end)
vim.keymap.set('n', '<Tab>q', function()
  vim.iter(vim.api.nvim_list_bufs()):each(function(buf)
    vim.api.nvim_buf_delete(buf, { force = true })
  end)
end)

-- Terminal
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { noremap = true })
vim.keymap.set('n', '<Leader>ts', function()
  vim.cmd.vnew()
  vim.cmd.term()
  vim.cmd.wincmd 'J'
  vim.api.nvim_win_set_height(0, 10)
end)
vim.keymap.set('t', '<C-h>', '<C-\\><C-n><C-w><C-h>')
vim.keymap.set('t', '<C-j>', '<C-\\><C-n><C-w><C-j>')
vim.keymap.set('t', '<C-k>', '<C-\\><C-n><C-w><C-k>')
vim.keymap.set('t', '<C-l>', '<C-\\><C-n><C-w><C-l>')

-- Splits
vim.keymap.set('n', '\\', '<Cmd>vsplit<CR>')
vim.keymap.set('n', '|', '<Cmd>split<CR>')

vim.keymap.set('n', '<Leader>a', 'ggVG')
vim.keymap.set('n', '<Leader>tw', '<Cmd>set wrap!<CR>', { desc = '[T]oggle [W]rap' })
vim.keymap.set('v', '<Leader>x', ':lua<CR>')

vim.keymap.set('n', '<C-n>', '<Cmd>nohls<CR>')

-- Folds
vim.keymap.set({ 'n', 'v' }, '<Leader>zf', 'zf', { remap = false })
vim.keymap.set({ 'n', 'v' }, '<Leader>zf', 'zf', { remap = false })
vim.keymap.set({ 'n', 'v' }, '<Leader>zf', 'zf', { remap = false })

-- Move between windows
vim.keymap.set('n', '<C-h>', '<C-w><C-h>')
vim.keymap.set('n', '<C-l>', '<C-w><C-l>')
vim.keymap.set('n', '<C-j>', '<C-w><C-j>')
vim.keymap.set('n', '<C-k>', '<C-w><C-k>')

vim.keymap.set('n', '<C-w>h', '<C-w>H')
vim.keymap.set('n', '<C-w>l', '<C-w>L')
vim.keymap.set('n', '<C-w>j', '<C-w>J')
vim.keymap.set('n', '<C-w>k', '<C-w>K')

-- Indent with <Alt-h> and <Alt-l>
vim.keymap.set('n', '<A-h>', '<<')
vim.keymap.set('n', '<A-l>', '>>')
vim.keymap.set('v', '<A-h>', '<gv')
vim.keymap.set('v', '<A-l>', '>gv')

-- Move with <Alt-j> and <Alt-k>
vim.keymap.set('n', '<A-j>', '<Cmd>m+1<CR>')
vim.keymap.set('n', '<A-k>', '<Cmd>m-2<CR>')
vim.keymap.set('v', '<A-j>', ":m'>+1<CR>gv")
vim.keymap.set('v', '<A-k>', ":m'<-2<CR>gv")

vim.keymap.set('n', 'g;', '@:', { desc = 'Repeat Ex' })

-- Move in insert and command mode
vim.keymap.set({ 'i', 'c' }, '<A-h>', '<Left>')
vim.keymap.set({ 'i', 'c' }, '<A-l>', '<Right>')
vim.keymap.set({ 'i', 'c' }, '<Left>', '<Nop>')
vim.keymap.set({ 'i', 'c' }, '<Right>', '<Nop>')

-- Completion
vim.keymap.set('i', '<C-f>', '<C-X><C-F>')
vim.keymap.set('i', '<C-l>', '<C-X><C-L>')

-- Misc
vim.keymap.set('n', '<Leader><Leader>', 'zz', { noremap = true })

vim.keymap.set({ 'n', 'v' }, '<Leader>/', function()
  return vim.api.nvim_get_mode().mode == 'n' and 'gcc' or 'gc'
end, {
  expr = true,
  remap = true,
  desc = 'Toggle comment',
})
