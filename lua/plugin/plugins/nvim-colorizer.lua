---@type PlugSpec
return {
  src = 'https://github.com/catgoose/nvim-colorizer.lua',
  setup = function()
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
