---@type PlugSpec
return {
  src = 'https://github.com/jinh0/eyeliner.nvim',
  setup = function()
    require('eyeliner').setup {
      default_keymaps = false,
      highlight_on_key = true,
      dim = true,
    }
  end,
}
