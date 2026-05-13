local M = {}

function M.get_buf(uri) return vim._tointeger(uri:match '^git%-pack://(%d+)$') end

function M.safe_set_lines(buf, start, end_, strict_indexing, replacement)
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, start, end_, strict_indexing, replacement)
  vim.bo[buf].modifiable = false
end

function M.bind_scroll(win_a, win_b)
  vim.wo[win_a].scrollbind = true
  vim.wo[win_b].scrollbind = true
  vim.api.nvim_create_autocmd('WinClosed', {
    callback = function(ev)
      if tonumber(ev.match) == win_a then
        vim.api.nvim_win_close(win_b, true)
        return true
      elseif tonumber(ev.match) == win_b then
        vim.api.nvim_win_close(win_a, true)
        return true
      end
    end,
  })
end

function M.parse_iso8601_utc(s)
  local year, month, day, hour, min, sec, tz = s:match '^(%d+)%-(%d+)%-(%d+)T(%d+):(%d+):(%d+)(.+)$'
  local ret = os.time {
    year = year,
    month = month,
    day = day,
    hour = hour,
    min = min,
    sec = sec,
    isdst = false,
  }

  if tz ~= 'Z' then
    local tz_sign, tz_hour, tz_min = tz:match '([+-])(%d+):(%d+)'
    local offset = tonumber(tz_hour) * 3600 + tonumber(tz_min) * 60
    ret = tz_sign == '+' and ret - offset or ret + offset
  end

  return ret
end

function M.since(ts)
  ---@diagnostic disable-next-line: param-type-mismatch
  local d = os.time(os.date '!*t') - ts

  local units = { { 60 * 60 * 24, 'd' }, { 60 * 60, 'h' }, { 60, 'm' }, { 1, 's' } }
  for _, u in ipairs(units) do
    if d >= u[1] then return (d - d % u[1]) / u[1] .. u[2] end
  end

  return '0s'
end

---@alias AnsiHighlight {codes: integer[], start: integer, end_: integer?}

---@param s string
---@return string[], AnsiHighlight[][]
function M.parse_ansi(s)
  local ln_hls = {} ---@type AnsiHighlight[][]
  local clean_lns = vim
    .iter(string.gmatch(s, '[^\n]+'))
    :map(function(ln)
      local function find_all(str, pattern)
        local ret, start, offset = {}, 1, 0
        while true do
          local s, e, c = string.find(str, pattern, start)
          if not s then break end
          start = e + 1
          s = vim.str_utfindex(str, 'utf-8', s - 1) + 1
          e = vim.str_utfindex(str, 'utf-8', e - 1) + 1
          ret[#ret + 1] = { start = s - offset, end_ = e - offset, cap = c }
          offset = offset + (e - s + 1)
        end
        return ret
      end

      ---@type AnsiHighlight[]
      local hls = vim
        .iter(find_all(ln, '\x1b%[([%d;]+)m'))
        :map(function(match)
          local codes = vim.iter(string.gmatch(match.cap, '(%d+)')):map(tonumber):totable()
          return { codes = codes, start = match.start }
        end)
        :totable()

      for i, hl in ipairs(hls) do
        if hl.codes[1] == 0 then
          for j = i - 1, 1, -1 do
            if hls[j].codes[1] == 0 or hls[j].end_ ~= nil then break end
            hls[j].end_ = hl.start
          end
        end
      end

      ln_hls[#ln_hls + 1] = hls

      local new_ln, _ = string.gsub(ln, '\x1b%[([%d;]+)m', '')
      return new_ln
    end)
    :totable()

  return clean_lns, ln_hls
end

return M
