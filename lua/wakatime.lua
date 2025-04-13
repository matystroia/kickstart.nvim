local interval = 5 * 60
local today = nil

local function refresh()
  vim.system({ 'wakatime-cli', '--today' }, { text = true }, function(result)
    local hours, minutes = result.stdout:match '(%d+) hrs?', result.stdout:match '(%d+) mins?'
    today = { hours = tonumber(hours) or 0, minutes = tonumber(minutes) or 0 }
  end)
  vim.defer_fn(refresh, interval * 1000)
end

refresh()

return {
  today = function()
    return today
  end,
}
