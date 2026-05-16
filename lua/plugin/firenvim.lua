if vim.g.started_by_firenvim then
  vim.g.firenvim_config = {
    localSettings = {
      ['.*'] = {
        cmdline = 'neovim',
        content = 'text',
        priority = 0,
        selector = 'textarea',
        takeover = 'never',
      },
      -- TODO: Get github filetype
      ['.+'] = {
        cmdline = 'neovim',
        content = 'text',
        priority = 1,
        selector = 'textarea[class=myTextArea]',
        takeover = 'always',
      },
    },
  }

  vim.o.number = false
  vim.o.relativenumber = false
  vim.o.laststatus = 0
  vim.o.signcolumn = 'no'
  vim.o.wrap = true
  vim.o.cmdheight = 0
  vim.o.scrolloff = 0

  vim.o.spell = true
  vim.o.spelllang = 'en_us,ro'

  -- TODO: This seems to not be wide enough for italics...
  vim.o.guifont = 'JetBrains Mono:h12'

  vim.keymap.set('n', 'j', 'gj')
  vim.keymap.set('n', 'k', 'gk')

  vim.keymap.set('n', '<Esc><Esc>', '<Cmd>w|call firenvim#hide_frame()<CR>')
  vim.api.nvim_create_autocmd('BufEnter', {
    pattern = 'github.com_*.txt',
    command = 'set filetype=markdown',
  })

  local group = vim.api.nvim_create_augroup('firenvim', { clear = true })
  vim.api.nvim_create_autocmd('UIEnter', {
    group = group,
    callback = function()
      local client = vim.api.nvim_get_chan_info(vim.v.event.chan).client
      if client ~= nil and client.name == 'Firenvim' then
        -- FIXME: When it starts working correctly
        vim.schedule(function()
          require('vim._core.ui2').enable {
            enable = true,
            msg = {
              targets = 'cmd',
              cmd = { height = 1 },
            },
          }
          vim.o.cmdheight = 0
        end)
      end
    end,
  })
  ---@type table<number, uv.uv_timer_t>
  local timers = {}
  vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
    group = group,
    callback = function(ev)
      if vim.list_contains({ 'cmd', 'msg', 'pager', 'dialog' }, vim.bo[ev.buf].filetype) then return end
      if timers[ev.buf] ~= nil then return end
      timers[ev.buf] = vim.uv.new_timer()
      if timers[ev.buf] == nil then return end
      timers[ev.buf]:start(100, 0, function()
        timers[ev.buf]:stop()
        timers[ev.buf]:close()
        timers[ev.buf] = nil
        vim.schedule(function() vim.cmd 'silent write' end)
      end)
    end,
  })
end

---@type PlugSpec
return {
  src = 'https://github.com/glacambre/firenvim',
  enabled = vim.g.started_by_firenvim == true,
  build = function() vim.cmd.call 'firenvim#install(0)' end,
}
