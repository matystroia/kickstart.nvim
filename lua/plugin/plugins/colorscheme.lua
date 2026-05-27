---@type table<string, PlugSpec>
local colorschemes = {
  tokyonight = {
    src = 'https://github.com/folke/tokyonight.nvim',
    priority = 100,
    setup = function()
      require('tokyonight').setup {
        style = 'moon',
        on_colors = function(colors) colors.bg_float = colors.bg_dark1 end,
      }
      vim.cmd.colorscheme 'tokyonight'
    end,
  },
  kanagawa = {
    src = 'https://github.com/rebelot/kanagawa.nvim',
    priority = 100,
    setup = function()
      require('kanagawa').setup {
        theme = 'wave',
        colors = {
          theme = {
            all = {
              ui = { bg_gutter = 'none' },
            },
          },
        },
        overrides = function(colors)
          local theme = colors.theme
          return {
            MsgSeparator = { link = 'Normal' },

            Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 },
            PmenuSel = { fg = 'NONE', bg = theme.ui.bg_p2 },
            PmenuSbar = { bg = theme.ui.bg_m1 },
            PmenuThumb = { bg = theme.ui.bg_p2 },

            TelescopeTitle = { fg = theme.ui.special, bold = true },
            TelescopePromptNormal = { bg = theme.ui.bg_p1 },
            TelescopePromptBorder = { fg = theme.ui.bg_p1, bg = theme.ui.bg_p1 },
            TelescopeResultsNormal = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m1 },
            TelescopeResultsBorder = { fg = theme.ui.bg_m1, bg = theme.ui.bg_m1 },
            TelescopePreviewNormal = { bg = theme.ui.bg_dim },
            TelescopePreviewBorder = { bg = theme.ui.bg_dim, fg = theme.ui.bg_dim },
          }
        end,
      }
      vim.cmd.colorscheme 'kanagawa'
    end,
  },
  gruvbox = {
    src = 'https://github.com/ellisonleao/gruvbox.nvim',
    priority = 100,
    setup = function()
      require('gruvbox').setup { contrast = 'hard' }
      vim.cmd.colorscheme 'gruvbox'
    end,
  },
}

return colorschemes.kanagawa
