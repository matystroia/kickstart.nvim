local today
local interval = 10 * 60

local function get_today()
  vim.system({ 'wakatime-cli', '--today' }, { text = true }, function(result)
    local hours = tonumber(result.stdout:match '(%d+) hrs?') or 0
    local minutes = tonumber(result.stdout:match '(%d+) mins?') or 0
    today = { hours = hours, minutes = minutes }
  end)
end

return {
  setup = function()
    local timer, err = vim.uv.new_timer()
    if timer == nil then
      return vim.notify('WakaTime: ' .. err, vim.log.levels.ERROR)
    end

    local group = vim.api.nvim_create_augroup('wakatime-timer', { clear = true })
    vim.api.nvim_create_autocmd('VimEnter', {
      group = group,
      callback = function()
        timer:start(0, interval * 1000, get_today)
      end,
    })
    vim.api.nvim_create_autocmd('VimLeavePre', {
      group = group,
      callback = function()
        timer:close()
      end,
    })
  end,
  today = function()
    return today
  end,
}
