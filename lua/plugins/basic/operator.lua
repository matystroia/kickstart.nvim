--- @type (LazyPluginSpec | string)[]
return {
  -- TODO: Look at all mini.nvim plugins
  {
    'nvim-mini/mini.surround',
    opts = {
      n_lines = 500,
    },
  },
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {},
  },
}
