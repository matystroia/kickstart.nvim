local whitelist = vim
  .iter({
    'plugins.basic.motion',
    'plugins.basic.operator',
    'plugins.ui.colorscheme',
  })
  :fold({}, function(acc, v)
    if v:match '[%a%-%.]/[%a%-%.]' then
      acc[v] = true
    else
      vim.iter(require(v)):each(function(vv)
        if type(vv) == 'string' then
          acc[vv] = true
        else
          acc[vv[1]] = true
        end
      end)
    end
    return acc
  end)

local function setup()
  vim.o.number = false
  vim.o.relativenumber = false
  vim.o.laststatus = 0
  vim.o.signcolumn = 'no'
  vim.opt.fillchars = { eob = ' ' }

  -- TODO: This seems to not be wide enough for italics...
  vim.o.guifont = 'Monaspace_Argon:h10'

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

return {
  spec = {
    'glacambre/firenvim',
    build = ':call firenvim#install(0)',
    cond = function()
      return vim.g.started_by_firenvim
    end,
    init = function()
      vim.g.firenvim_config = {
        localSettings = {
          ['.*'] = {
            cmdline = 'firenvim',
            content = 'text',
            priority = 0,
            selector = 'textarea',
            takeover = 'never',
          },
          ['github.com'] = {
            priority = 1,
            takeover = 'always',
          },
        },
      }
    end,
  },
  whitelist = whitelist,
  plugin_cond = function(plugin)
    return not vim.g.started_by_firenvim or whitelist[plugin[1]]
  end,
  setup = setup,
}
