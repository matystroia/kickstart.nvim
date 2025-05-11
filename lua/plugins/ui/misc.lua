--- @type (LazyPluginSpec | string)[]
return {
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {
      indent = { char = '▏' },
      scope = { enabled = false },
    },
  },
  {
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
  },
}
