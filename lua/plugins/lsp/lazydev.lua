---@type LazyPluginSpec
return {
  'folke/lazydev.nvim',
  ft = 'lua',
  opts = {
    library = {
      { path = 'lazy.nvim', words = { 'LazyPluginSpec' } },
      { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      { path = '$HOME/git/wezterm-types', mods = { 'wezterm' } },
      { path = '/usr/share/lua/5.1/fun.lua', mods = { 'fun' } },
    },
    enabled = function(root_dir)
      return not vim.uv.fs_stat(root_dir .. '/.luarc.json')
    end,
  },
}
