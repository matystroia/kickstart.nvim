local M = {
  state = {},
}

local util = require 'custom.gitlog.util'

local ns = vim.api.nvim_create_namespace 'GitCommit'

vim.api.nvim_set_hl(0, 'CommitSha', { link = '@variable.builtin' })
vim.api.nvim_set_hl(0, 'CommitFeature', { link = 'Title' })
vim.api.nvim_set_hl(0, 'CommitChore', { link = 'Conceal' })
vim.api.nvim_set_hl(0, 'CommitVim', { link = 'String' })

-- vim.api.nvim_set_hl(0, 'AnsiBold', { bold = true })
-- vim.api.nvim_set_hl(0, 'AnsiDim', { dim = true })
-- vim.api.nvim_set_hl(0, 'AnsiBlack', { link = 'MiniIconsBlack' })
vim.api.nvim_set_hl(0, 'AnsiRed', { link = 'MiniIconsRed' })
vim.api.nvim_set_hl(0, 'AnsiGreen', { link = 'MiniIconsGreen' })
-- vim.api.nvim_set_hl(0, 'AnsiYellow', { link = 'MiniIconsYellow' })
-- vim.api.nvim_set_hl(0, 'AnsiBlue', { link = 'MiniIconsBlue' })
-- vim.api.nvim_set_hl(0, 'AnsiMagenta', { link = 'MiniIconsMagenta' })
-- vim.api.nvim_set_hl(0, 'AnsiCyan', { link = 'MiniIconsCyan' })
-- vim.api.nvim_set_hl(0, 'AnsiWhite', { link = 'MiniIconsWhite' })

---@return integer, any?
function M.get_row(buf, row)
  local row = row or vim.api.nvim_win_get_cursor(0)[1]
  local sha = vim.api.nvim_buf_get_text(buf, row - 1, 0, row - 1, 7, {})[1]

  if sha == nil or sha:match '%s' ~= nil then return row, nil end

  local _, c = vim.iter(M.state[buf].commit_map):find(function(k, _) return vim.startswith(k, sha) end)

  return row, c
end

function M.get_commits(buf)
  vim.system(
    { 'git', 'log', '--pretty=format:%H%x00%an%x00%ae%x00%aI%x00%B%x1e', '-n' .. M.state[buf].opts.n },
    { cwd = M.state[buf].opts.path, text = true },
    function(out)
      if out.code ~= 0 then
        vim.notify('Error: ' .. (out.stderr or '?'))
        return
      end

      ---@type Commit[]
      local commits = vim
        .iter(out.stdout:gmatch '([^\30]+)\30\n')
        :map(function(commit)
          local p = vim.iter(commit:gmatch '[^%z]+'):totable()
          return {
            sha = p[1],
            author_name = p[2],
            author_email = p[3],
            timestamp = util.parse_iso8601_utc(p[4]),
            message = p[5],
          }
        end)
        :totable()

      M.state[buf] = vim.tbl_extend('force', M.state[buf], {
        commits = commits,
        commit_map = vim.iter(commits):fold({}, function(acc, c)
          acc[c.sha] = c
          return acc
        end),
        expanded = {},
      })
      vim.schedule(function() M.insert_commits(buf) end)
    end
  )
end

---@class Commit
---@field sha string
---@field author_name string
---@field author_email string
---@field timestamp integer
---@field message string

---@param opts {path: string}
function M.open(opts)
  local buf = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_buf_set_name(buf, 'git-pack://' .. buf)
  vim.bo[buf].ft = 'gitlog'
  vim.api.nvim_win_set_buf(0, buf)

  M.state[buf] = {
    opts = opts,
  }

  M.get_commits(buf)

  vim.keymap.set('n', '<CR>', function()
    local row, c = M.get_row(buf)
    if c ~= nil then M.expand(buf, row, c) end
  end, { buf = buf })

  vim.keymap.set('n', 'gf', function()
    local progress = {
      kind = 'progress',
      percent = nil,
      source = 'git-log',
      status = 'running',
      title = 'git',
    }
    progress.id = vim.api.nvim_echo({ { 'fetching' } }, true, progress)

    vim.system({ 'git', 'fetch' }, { cwd = opts.path }, function(out)
      if out.code ~= 0 then
        vim.schedule(
          function()
            vim.api.nvim_echo(
              { { 'error: ' .. (out.stderr or '?') } },
              true,
              vim.tbl_extend('force', progress, { status = 'failed' })
            )
          end
        )
        return
      end

      vim.schedule(
        function() vim.api.nvim_echo({ { 'done' } }, true, vim.tbl_extend('force', progress, { status = 'success' })) end
      )

      M.get_commits(buf)
    end)
  end, { buf = buf })

  vim.keymap.set('n', 'gd', function()
    local row, c = M.get_row(buf)
    if c ~= nil then M.open_diff(buf, row, c) end
  end, { buf = buf })

  vim.lsp.start({
    cmd = M.lsp_cmd,
    name = 'git.pack',
    root_dir = vim.uv.cwd(),
  }, { bufnr = buf, attach = true })

  vim.bo[buf].modifiable = false
end

function M.expand(buf, row, c)
  local msg_lines = vim
    .iter(vim.split(c.message, '\n', { plain = true }))
    :skip(1)
    :map(function(ln) return #ln > 0 and (string.rep(' ', 8) .. ln) or '' end)
    :totable()

  if not vim.tbl_isempty(msg_lines) and #msg_lines[#msg_lines] > 0 then table.insert(msg_lines, '') end

  if M.state[buf].expanded[c.sha] then
    M.state[buf].expanded[c.sha] = false
    util.safe_set_lines(buf, row, row + #msg_lines, true, {})
    return
  end

  M.state[buf].expanded[c.sha] = true
  util.safe_set_lines(buf, row, row, true, msg_lines)

  vim.iter(msg_lines):enumerate():each(function(i, ln)
    local match = ln:match '^%s*Problem:'
    if match ~= nil then
      vim.hl.range(buf, ns, 'CommitChore', { row + i - 1, 8 }, { row + i - 1, #match })
    else
      match = ln:match '^%s*Solution:'
      if match ~= nil then vim.hl.range(buf, ns, 'CommitChore', { row + i - 1, 8 }, { row + i - 1, #match }) end
    end
  end)
end

function M.open_diff(buf, row, c)
  local width = vim.api.nvim_win_get_width(0)
  local diff = vim
    .system({
      'git',
      '-c',
      'diff.external=difft --color=always --display=side-by-side-show-both --syntax-highlight=off --width=' .. width,
      'diff',
      c.sha .. '^!',
    }, { cwd = M.state[buf].opts.path, text = true })
    :wait().stdout ---@cast diff string

  local lns, ln_hls = util.parse_ansi(diff)

  local left_lns, right_lns, left_hls, right_hls = {}, {}, {}, {}
  local function insert_ln(left, right)
    table.insert(left_lns, left)
    table.insert(right_lns, right)
  end

  local i = 1
  while i <= #lns do
    insert_ln(lns[i], lns[i])
    table.insert(left_hls, ln_hls[i])
    table.insert(right_hls, ln_hls[i])

    i = i + 1
    local group_lns = {} ---@type string[]
    while i <= #lns and string.match(lns[i], '^[a-zA-Z]') == nil do
      table.insert(group_lns, lns[i])
      i = i + 1
    end

    local right_start
    for j = vim.str_utfindex(group_lns[1], 'utf-8') - 1, 6, -1 do
      if
        vim
          .iter(group_lns)
          :all(function(ln) return j < #ln and string.match(vim.fn.strcharpart(ln, j, 1), '[%d%.]') ~= nil end)
      then
        right_start = j
        while vim.fn.strcharpart(group_lns[#group_lns], right_start - 1, 1):match '%d' do
          right_start = right_start - 1
        end
        break
      end
    end

    vim.iter(group_lns):enumerate():each(function(j, ln)
      local left_ln = vim.fn.strcharpart(ln, 0, right_start - 1)
      local right_ln = vim.fn.strcharpart(ln, right_start)
      insert_ln(left_ln:gsub(' +$', ''), right_ln:gsub(' +$', ''))

      table.insert(left_hls, {})
      table.insert(right_hls, {})
      vim.iter(ln_hls[i + j - #group_lns - 1]):each(function(hl)
        if hl.start < right_start then
          table.insert(left_hls[#left_hls], hl)
        else
          local start, end_ = hl.start - vim.str_utfindex(left_ln, 'utf-8') - 1, nil
          if hl.end_ ~= nil then end_ = hl.end_ - vim.str_utfindex(left_ln, 'utf-8') - 1 end
          table.insert(right_hls[#right_hls], { codes = hl.codes, start = start, end_ = end_ })
        end
      end)
    end)
  end

  local function create_diff_buf(contents, name)
    if vim.fn.bufexists(name) == 1 then vim.cmd.bwipe(name) end
    local diff_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(diff_buf, 0, -1, true, contents)
    vim.api.nvim_buf_set_name(diff_buf, name)

    vim.bo[diff_buf].ft = 'difft'
    vim.bo[diff_buf].modifiable = false
    return diff_buf
  end

  local left_buf = create_diff_buf(left_lns, 'diff://before')
  local right_buf = create_diff_buf(right_lns, 'diff://after')

  local function create_diff_win(diff_buf, opts)
    local win = vim.api.nvim_open_win(diff_buf, false, opts)
    vim.wo[win].number = false
    vim.wo[win].relativenumber = false
    vim.wo[win].signcolumn = 'no'
    vim.wo[win].foldcolumn = '0'
    return win
  end

  local left_win = create_diff_win(left_buf, { split = 'below', win = 0 })
  local right_win = create_diff_win(right_buf, { split = 'right', win = left_win })
  util.bind_scroll(left_win, right_win)

  vim.api.nvim_create_autocmd('WinClosed', {
    callback = function(ev)
      if tonumber(ev.match) == left_win then
        vim.api.nvim_buf_del_extmark(buf, ns, M.state[buf].diff_ext)
        return true
      end
    end,
  })

  local hl_groups = {
    [1] = 'AnsiBold',
    [2] = 'AnsiDim',
    [90] = 'AnsiBlack',
    [91] = 'AnsiRed',
    [92] = 'AnsiGreen',
    [93] = 'AnsiYellow',
    [94] = 'AnsiBlue',
    [95] = 'AnsiMagenta',
    [96] = 'AnsiCyan',
    [97] = 'AnsiWhite',
  }

  local function hl_buf(buf, buf_lns, hls)
    for i, line_hls in ipairs(hls) do
      local ln = buf_lns[i]
      vim.iter(line_hls):each(function(hl)
        vim.iter(hl.codes):each(function(code)
          local hl_group = hl_groups[code]
          if hl_group ~= nil then
            vim.hl.range(buf, ns, hl_group, { i - 1, hl.start - 1 }, { i - 1, (hl.end_ or #ln) - 1 })
          end
        end)
      end)
    end
  end

  hl_buf(left_buf, left_lns, left_hls)
  hl_buf(right_buf, right_lns, right_hls)

  M.state[buf].diff_ext = vim.api.nvim_buf_set_extmark(
    buf,
    ns,
    row - 1,
    8,
    { id = M.state[buf].diff_ext, virt_text = { { '■ ', 'DiagnosticWarn' } }, virt_text_pos = 'inline' }
  )
end

function M.mk_commit_ln(c)
  local sha = c.sha:sub(0, 7) ---@type string
  local msg = c.message ---@type string
  local summary = msg:match '^[^\n]+'

  local ln, hls = '', {}

  local function add_substr(s, hl)
    local ln_len = vim.str_utfindex(ln, 'utf-8')
    if hl ~= nil then hls[#hls + 1] = { hl, ln_len, ln_len + vim.str_utfindex(s, 'utf-8') } end
    ln = ln .. s
  end

  add_substr(sha, 'CommitSha')
  add_substr ' '

  local prefix = msg:match '^([^ ]+): '
  if prefix ~= nil then
    if prefix:match '^vim%-patch' ~= nil then
      hls[#hls + 1] = { 'String', #ln, #ln + #prefix + 1 }
    else
      local type, subtype, breaking = prefix:match '^[a-z]+', prefix:match '%([a-z%.]+%)$', prefix:match '!$'
      local hl = vim.tbl_contains({ 'docs', 'ci', 'test', 'revert' }, type) and 'CommitChore' or 'CommitFeature'
      hls[#hls + 1] = { hl, #ln, #ln + #prefix + 1 }

      if breaking ~= nil then hls[#hls + 1] = { 'ErrorMsg', #ln + #prefix - 1, #ln + #prefix } end
    end
  else
    hls[#hls + 1] = { 'Comment', #ln, #ln + #summary }
  end

  add_substr(summary)
  add_substr ' '
  add_substr(util.since(c.timestamp) .. ', ' .. c.author_name, 'Comment')

  return ln, hls
end

function M.insert_commits(buf)
  local lns, ln_hls = {}, {}
  vim.iter(M.state[buf].commits):map(M.mk_commit_ln):each(function(ln, hls)
    table.insert(lns, ln)
    table.insert(ln_hls, hls)
  end)

  util.safe_set_lines(buf, 0, -1, true, lns)

  vim.iter(ln_hls):enumerate():each(function(i, hls)
    vim.iter(hls):each(function(hl) vim.hl.range(buf, ns, hl[1], { i - 1, hl[2] }, { i - 1, hl[3] }) end)
  end)
end

-- TODO: Simplify after `vim.lsp.server` is a thing
-- https://github.com/neovim/neovim/pull/24338
function M.lsp_cmd(dispatchers)
  local closing = false
  local request_id = 0

  local srv = {} ---@type vim.lsp.rpc.Client
  function srv.request(method, params, callback)
    if method == 'initialize' then
      callback(nil, {
        capabilities = {
          documentLinkProvider = { resolveProvider = false },
          hoverProvider = true,
        },
      }, request_id)
    elseif method == 'shutdown' then
      callback(nil, nil, request_id)
    elseif method == 'textDocument/hover' then
      local buf = util.get_buf(params.textDocument.uri)
      vim.schedule(function()
        local row = params.position.line + 1
        local _, c = M.get_row(buf, row)
        vim.system(
          { 'git', 'diff', '--shortstat', c.sha .. '^!' },
          { text = true, cwd = M.state[buf].opts.path },
          function(out)
            vim.schedule(
              function()
                callback(
                  nil,
                  { contents = { kind = vim.lsp.protocol.MarkupKind.PlainText, value = out.stdout } },
                  request_id
                )
              end
            )
          end
        )
      end)
    elseif method == 'textDocument/documentLink' then
      local buf = util.get_buf(params.textDocument.uri)
      local links = vim
        .iter(M.state[buf].commits)
        :enumerate()
        :map(function(i, c)
          local target = require('vim._core.util').get_forge_url('https://github.com/neovim/neovim', c.sha, 'commit')
          return {
            range = {
              start = { line = i - 1, character = 0 },
              ['end'] = { line = i - 1, character = 7 },
            },
            target = target,
          }
        end)
        :totable()
      callback(nil, links, request_id)
    end
    request_id = request_id + 1
    return true, request_id
  end
  function srv.notify(method, params)
    if method == 'exit' then dispatchers.on_exit(0, 15) end
    return true
  end
  function srv.is_closing() return closing end
  function srv.terminate() closing = true end

  return srv
end

return M
