---@type LazyPluginSpec
return {
  'catgoose/nvim-colorizer.lua',
  event = 'BufReadPre',
  config = function()
    local colorizer = require 'colorizer'
    colorizer.setup {
      lazy_load = true,
      user_default_options = {
        names = false,
        rgb_fn = true,
        RRGGBB = true,
        mode = 'virtualtext',
        virtualtext = '',
      },
    }
  end,
}
