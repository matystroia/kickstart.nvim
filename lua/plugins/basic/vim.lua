---@type LazyPluginSpec[]
return {
  { 'tpope/vim-fugitive' },
  { 'tpope/vim-eunuch' },
  {
    'elkowar/yuck.vim',
    ft = 'yuck',
    dependencies = {
      { 'eraserhd/parinfer-rust', build = 'cargo build --release' },
    },
  },
  {
    'tridactyl/vim-tridactyl',
    ft = 'tridactyl',
  },
}
