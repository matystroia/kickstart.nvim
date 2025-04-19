--- @type (LazyPluginSpec | string)[]
return {
  'tpope/vim-repeat',
  'tpope/vim-surround',
  -- TODO: Look at all mini.nvim plugins
  {
    'echasnovski/mini.ai',
    opts = { n_lines = 500 },
  },
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {},
  },
}
