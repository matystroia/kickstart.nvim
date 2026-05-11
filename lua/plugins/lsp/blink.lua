---@type LazyPluginSpec
return {
  'saghen/blink.cmp',
  branch = 'main',
  dependencies = {
    'saghen/blink.lib',
    'L3MON4D3/LuaSnip',
    'folke/lazydev.nvim',
  },
  build = function()
    require('blink.cmp'):build()
  end,

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = { preset = 'default' },
    appearance = { nerd_font_variant = 'normal' },
    completion = {
      menu = { border = 'none' },
      list = { selection = { auto_insert = false } },
      documentation = { auto_show = false },
    },
    sources = {
      default = { 'lsp', 'path', 'snippets' },
      providers = {
        lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
      },
    },
    fuzzy = { implementation = 'rust' },
    snippets = { preset = 'luasnip' },
    signature = {
      enabled = true,
      trigger = { show_on_accept = true },
      window = { show_documentation = false },
    },
  },
}
