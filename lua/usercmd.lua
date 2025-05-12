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

  local path = vim.fn.FugitivePath():gsub('^' .. vim.fn.FugitiveWorkTree() .. '/', '')

  local lines = ''
  if opts.range ~= 0 then
    lines = string.format('#L%d-L%d', opts.line1, opts.line2)
  end

  -- TODO: Absolute commit path
  -- TODO: Prompt if permanent or not
  local url = string.format('https://github.com/%s/blob/%s/%s%s', remote_path, head, path, lines)

  vim.fn.setreg('+', url)
  vim.print 'Copied to clipboard'
end, { range = true, desc = 'Get GitHub URL' })
