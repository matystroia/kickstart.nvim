---@type PlugSpec
return {
  src = 'https://github.com/folke/lazydev.nvim',
  enabled = false,
  setup = function()
    require('lazydev').setup {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
        { path = '$HOME/git/wezterm-types', mods = { 'wezterm' } },
        { path = '/usr/share/lua/5.1/fun.lua', mods = { 'fun' } },
      },
      enabled = function(root_dir)
        return not vim.uv.fs_stat(root_dir .. '/.luarc.json')
      end,
    }
  end,
}
