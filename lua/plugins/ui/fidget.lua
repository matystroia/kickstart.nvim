---@type LazyPluginSpec
return {
  'j-hui/fidget.nvim',
  config = function()
    local fidget = require 'fidget'
    local default_notification = vim.tbl_extend('force', fidget.notification.default_config, {
      icon = '',
      error_annote = '󰅚 ',
      warn_annote = '󰀪 ',
      info_annote = '󰋽 ',
      debug_annote = '󰌶 ',
    })

    fidget.setup {
      notification = {
        override_vim_notify = true,
        window = { border = 'rounded' },
        configs = { default = default_notification },
      },
    }
  end,
}
