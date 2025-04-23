--- @type (LazyPluginSpec | string)[]
return {
  'tpope/vim-repeat',
  'tpope/vim-surround',
  -- TODO: Look at all mini.nvim plugins
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {},
  },
}
