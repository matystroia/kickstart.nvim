local M = {}

---@type PlugSpec
M.spec = {
  src = 'https://github.com/glacambre/firenvim',
  build = function()
    vim.cmd.call 'firenvim#install(0)'
  end,
  setup = function()
    vim.g.firenvim_config = {
      localSettings = {
        ['.*'] = {
          cmdline = 'firenvim',
          content = 'text',
          priority = 0,
          selector = 'textarea',
          takeover = 'never',
        },
        -- TODO: Get github filetype
      },
    }
  end,
}

M.setup = function()
  vim.o.number = false
  vim.o.relativenumber = false
  vim.o.laststatus = 0
  vim.o.signcolumn = 'no'
  vim.o.wrap = true
  vim.o.cmdheight = 0
  vim.opt.fillchars = { eob = ' ' }

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

  vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
    callback = function()
      if vim.g.timer_started == true then
        return
      end
      vim.g.timer_started = true
      vim.fn.timer_start(5000, function()
        vim.g.timer_started = false
        vim.cmd 'silent write'
      end)
    end,
  })
end

M.whitelist = vim.iter({}):fold({}, function(acc, v)
  if v:match '[%a%-%.]/[%a%-%.]' then
    acc[v] = true
  else
    vim.iter(require(v)):each(function(vv)
      if type(vv) == 'string' then
        acc[vv] = true
      elseif vv.url ~= nil then
        acc[vv.url] = true
      else
        acc[vv[1]] = true
      end
    end)
  end
  return acc
end)

return M
