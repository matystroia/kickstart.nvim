local nvim_on = require('vim._core.util').nvim_on
local ns = vim.api.nvim_create_namespace 'cmdwin-highlight'

---@param regex vim.regex
---@param str string
---@param once boolean
---@return [integer, integer][]
local function match_all(regex, str, once)
  local ret, start = {}, 0
  while true do
    local s, e = regex:match_str(str:sub(start + 1))
    if not s or not e then break end
    table.insert(ret, { start + s, start + e })
    if once then return ret end
    if e == s then break end
    start = start + e
  end
  return ret
end

---@param buf integer
---@param ln_range [integer, integer]
---@param pattern string
---@param is_sub boolean
---@param substitute string?
---@param flags string?
---@return any
local function hl_pattern(buf, ln_range, pattern, is_sub, substitute, flags)
  local ok, re = pcall(vim.regex, pattern)
  if not ok then return end

  local lns = vim.api.nvim_buf_get_lines(buf, ln_range[1], ln_range[2], true)

  vim.iter(lns):enumerate():each(function(i, ln)
    local match_once = is_sub and (flags == nil or not flags:match 'g')
    local matches = match_all(re, ln, match_once)

    vim.iter(matches):each(function(m)
      local ext_opts = { end_col = m[2] }
      if is_sub and substitute == nil then
        ext_opts.hl_group = 'Substitute'
      elseif is_sub then
        ext_opts.conceal = true
      else
        ext_opts.hl_group = 'IncSearch'
      end

      vim.api.nvim_buf_set_extmark(buf, ns, ln_range[1] + i - 1, m[1], ext_opts)

      if substitute ~= nil then
        vim.api.nvim_buf_set_extmark(
          buf,
          ns,
          ln_range[1] + i - 1,
          m[2],
          { virt_text = { { substitute, 'Substitute' } }, virt_text_pos = 'inline' }
        )
      end
    end)
  end)
end

local group = vim.api.nvim_create_augroup('cmdwin-preview', { clear = true })
nvim_on('CmdwinEnter', group, { desc = 'Show search/substitute preview in command window' }, function()
  local cmd_type = vim.fn.getcmdwintype()
  if cmd_type ~= ':' and cmd_type ~= '/' then return end

  local target_win = vim.fn.win_getid(vim.fn.winnr '#')
  local target_buf = vim.api.nvim_win_get_buf(target_win)
  local cmd_buf = vim.api.nvim_get_current_buf()

  local function on_change()
    vim.api.nvim_buf_clear_namespace(target_buf, ns, 0, -1)
    local ln = vim.api.nvim_get_current_line():gsub('\\/', '\x1e')

    if cmd_type == '/' then
      if ln ~= '' then hl_pattern(target_buf, { 0, -1 }, ln:gsub('\x1e', '/'), false) end
      return
    end

    local ln_range
    if ln:match "^'<,'>s/" then
      local start, end_ = vim.api.nvim_buf_get_mark(target_buf, '<'), vim.api.nvim_buf_get_mark(target_buf, '>')
      ln_range = { start[1] - 1, end_[1] }
    elseif ln:match '^%d+,%d+s/' then
      local start, end_ = ln:match '^(%d+),(%d+)s/'
      ln_range = { vim._tointeger(start) - 1, vim._tointeger(end_) }
    elseif ln:match '^%%s/' then
      ln_range = { 0, -1 }
    elseif ln:match '^s/' then
      local pos = vim.api.nvim_win_get_cursor(target_win)
      ln_range = { pos[1] - 1, pos[1] }
    else
      return
    end
    ---@cast ln_range [integer, integer]

    local p = vim.split(ln, '/')
    local pat, s_pat, flags = p[2], p[3], p[4] ---@cast pat string

    if pat ~= nil then pat = pat:gsub('\x1e', '/') end
    if s_pat ~= nil then s_pat = s_pat:gsub('\x1e', '/') end

    if vim.bo[target_buf].modifiable then
      hl_pattern(target_buf, ln_range, pat, true, s_pat, flags)
    else
      hl_pattern(target_buf, ln_range, pat, false, nil, flags)
    end
  end

  local cole = vim.wo[target_win].conceallevel
  vim.wo[target_win].conceallevel = 2

  nvim_on({ 'TextChanged', 'TextChangedI', 'CursorMoved' }, group, { buf = cmd_buf }, function() on_change() end)

  nvim_on('CmdwinLeave', group, { buf = cmd_buf, once = true }, function()
    vim.wo[target_win].conceallevel = cole
    vim.api.nvim_buf_clear_namespace(target_buf, ns, 0, -1)
    vim.api.nvim_del_augroup_by_name 'cmdwin-preview'
  end)
end)
