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
    vim
      .iter(vim.lsp.get_clients { bufnr = vim.api.nvim_get_current_buf() })
      :each(function(client) vim.lsp.buf_attach_client(buf, client.id) end)
  end

  -- Replace save with format :)
  vim.keymap.set('n', '<Leader>w', '<Leader>f', { remap = true, buffer = buf })

  vim.api.nvim_set_current_buf(buf)
end, { nargs = '?', range = true, desc = 'Create scratch buffer' })

vim.api.nvim_create_user_command('GitHubUrl', function(opts)
  local remote = vim.fn.FugitiveRemote()
  if remote.host ~= 'github.com' then return vim.notify('Not a GitHub repo', vim.log.levels.ERROR) end

  local remote_path = remote.path:gsub('%.git$', '')
  local head = vim.fn.FugitiveHead()

  local path = vim.fn.FugitivePath():gsub('^' .. vim.fn.FugitiveWorkTree() .. '/', '')

  local lines = ''
  if opts.range ~= 0 then lines = string.format('#L%d-L%d', opts.line1, opts.line2) end

  -- TODO: Absolute commit path
  -- TODO: Prompt if permanent or not
  local url = string.format('https://github.com/%s/blob/%s/%s%s', remote_path, head, path, lines)

  vim.fn.setreg('+', url)
  vim.print 'Copied to clipboard'
end, { range = true, desc = 'Get GitHub URL' })

vim.api.nvim_create_user_command(
  'GitLog',
  function() require('custom.gitlog').open { path = vim.fn.FugitiveWorkTree() } end,
  { desc = 'Git commits in current repo' }
)

vim.api.nvim_create_user_command(
  'NeovimLog',
  function() require('custom.gitlog').open { path = vim.fs.normalize '~/.aur/neovim-git/neovim/', n = 200 } end,
  { desc = 'Git commits in Neovim repo' }
)

vim.api.nvim_create_user_command('Session', function(opts)
  local session = require 'custom.session'
  if opts.fargs[1] == nil then
    session.load_session()
  elseif opts.fargs[1] == 'new' then
    session.create_session()
  elseif opts.fargs[1] == 'save' then
    session.save_session()
  else
    vim.print 'Invalid command'
  end
end, { nargs = '?' })

vim.api.nvim_create_user_command('ColorPicker', function()
  local n = 12

  local ns = vim.api.nvim_create_namespace 'color-picker'
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(
    buf,
    true,
    { relative = 'cursor', row = 0, col = 0, style = 'minimal', width = n + 12, height = 3 }
  )

  -- TODO: Unicode chars
  local function slider(val) return string.rep('-', val) .. '|' .. string.rep('-', n - val) end

  local state, labels = { 0, 0, 0 }, { 'R ', 'G ', 'B ' }
  local function update_buf()
    local rgb = vim.iter(state):map(function(x) return math.floor(255 / n * x) end):totable()
    local color = vim.iter(rgb):rev():enumerate():fold(0, function(acc, i, x) return acc + x * math.pow(256, i - 1) end)
    local hex = '#' .. string.format('%06x', color)
    vim.api.nvim_set_hl(0, 'Swatch', { fg = hex })

    local lns = vim.iter(state):map(function(v) return slider(v) end):totable()
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, true, lns)
    vim.bo[buf].modifiable = false

    for i = 1, 3 do
      vim.api.nvim_buf_set_extmark(buf, ns, i - 1, 0, { virt_text = { { labels[i] } }, virt_text_pos = 'inline' })
      if i <= 2 then
        vim.api.nvim_buf_set_extmark(buf, ns, i - 1, 0, { virt_text = { { '███████', 'Swatch' } } })
      end
    end
    vim.api.nvim_buf_set_extmark(buf, ns, 2, 0, { virt_text = { { hex, 'Dimmed' } } })
  end

  local prev_pos = vim.api.nvim_win_get_cursor(win)
  vim.api.nvim_create_autocmd('CursorMoved', {
    callback = function()
      local pos = vim.api.nvim_win_get_cursor(win)
      if pos[1] ~= prev_pos[1] then
        vim.api.nvim_win_set_cursor(win, { pos[1], state[pos[1]] })
      else
        state[pos[1]] = pos[2]
        update_buf()
      end
      prev_pos = pos
    end,
    buf = buf,
  })
end, { desc = 'Simple color picker' })
