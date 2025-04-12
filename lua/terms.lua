local function set_alacritty_config(config, ...)
  vim.system { 'alacritty', 'msg', 'config', config, ... }
end

local function set_wezterm_var(name, value)
  -- Wezterm expects base64 encoded value
  local b64_value = vim.base64.encode(value or '')
  vim.api.nvim_chan_send(vim.v.stderr, '\027]1337;SetUserVar=' .. name .. '=' .. b64_value .. '\007')
end

local terminals = {
  alacritty = {
    cond = function()
      return vim.fn.getenv 'TERM' == 'alacritty'
    end,
    enter = function(bg_color)
      set_alacritty_config('window.padding = { x = 0, y = 0 }', 'colors.primary.background = "' .. bg_color .. '"')
    end,
    exit = function()
      set_alacritty_config '-r'
    end,
  },
  wezterm = {
    cond = function()
      return vim.fn.getenv 'TERM_PROGRAM' == 'WezTerm'
    end,
    enter = function(bg_color)
      set_wezterm_var('vim-enter', bg_color)
    end,
    exit = function()
      set_wezterm_var 'vim-exit'
    end,
  },
}

return {
  ---@param terms ('alacritty' | 'wezterm')[]
  setup = function(terms)
    terms = terms or {}

    local _, term = vim.iter(pairs(terminals)):find(function(k, v)
      return vim.list_contains(terms, k) and v.cond()
    end)

    if term == nil then
      return
    end

    local group = vim.api.nvim_create_augroup('TerminalPadding', { clear = true })
    vim.api.nvim_create_autocmd('ColorScheme', {
      callback = function()
        local bg_color = string.format('#%06x', vim.api.nvim_get_hl(0, { name = 'Normal' }).bg)
        term.enter(bg_color)
      end,
      group = group,
    })
    vim.api.nvim_create_autocmd('VimLeavePre', {
      callback = function()
        term.exit()
      end,
      group = group,
    })
  end,
}
