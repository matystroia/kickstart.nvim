local whitelist = vim
  .iter({
    'sainnhe/gruvbox-material',

    -- TODO: Only submodules
    -- 'echasnovski/mini.nvim',
    -- 'nvim-treesitter/nvim-treesitter',

    -- 'plugins.motion',
  })
  :fold({}, function(acc, v)
    if v:match '[%a%-%.]/[%a%-%.]' then
      acc[v] = true
    else
      for vv in vim.iter(require(v)) do
        acc[vv[1]] = true
      end
    end
    return acc
  end)

local function setup()
  vim.opt.number = false
  vim.opt.relativenumber = false
  vim.opt.laststatus = 0
  vim.opt.signcolumn = 'no'
  vim.opt.fillchars = { eob = ' ' }
  -- TODO: This seems to not be wide enough for italics...
  vim.opt.guifont = 'Monaspace_Argon:h10'

  vim.keymap.set('n', '<Esc><Esc>', '<Cmd>w|call firenvim#hide_frame()<CR>')
  vim.api.nvim_create_autocmd('BufEnter', {
    pattern = 'github.com_*.txt',
    command = 'set filetype=markdown',
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
