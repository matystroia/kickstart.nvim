---@type PlugSpec
return {
  src = 'https://github.com/saghen/blink.cmp',
  deps = {
    { src = 'https://github.com/saghen/blink.lib' },
    { src = 'https://github.com/L3MON4D3/LuaSnip' },
  },
  build = function() require('blink.cmp').build() end,
  setup = function()
    require('blink.cmp').setup {
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
    }
  end,
}
