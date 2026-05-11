---@type LazyPluginSpec
return {
  'jinh0/eyeliner.nvim',
  config = function()
    local eyeliner = require 'eyeliner'
    eyeliner.setup {
      default_keymaps = false,
      highlight_on_key = true,
      dim = true,
    }
  end,
}
