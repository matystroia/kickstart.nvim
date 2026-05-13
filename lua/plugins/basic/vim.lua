---@type PlugSpec[]
return {
  { src = 'https://github.com/tpope/vim-eunuch' },
  { src = 'https://github.com/tpope/vim-fugitive' },
  { src = 'https://github.com/tpope/vim-repeat' },
  { src = 'https://github.com/tridactyl/vim-tridactyl' },
  {
    src = 'https://github.com/wakatime/vim-wakatime',
    version = vim.version.range '11.3.0',
  },
}
