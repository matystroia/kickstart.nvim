return {
  {
    'saghen/blink.cmp',
    event = 'InsertEnter',
    build = 'cargo build --release',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        version = '2.*',
        build = 'make install_jsregexp',
        dependencies = {
          -- `friendly-snippets` contains a variety of premade snippets.
          --    See the README about individual language/framework/plugin snippets:
          --    https://github.com/rafamadriz/friendly-snippets
          -- {
          --   'rafamadriz/friendly-snippets',
          --   config = function()
          --     require('luasnip.loaders.from_vscode').lazy_load()
          --   end,
          -- },
        },
        opts = {
          region_check_events = { 'InsertEnter' },
        },
      },
      'folke/lazydev.nvim',
    },
    config = function()
      local blink = require 'blink.cmp'
      blink.setup {
        keymap = {
          -- For an understanding of why the 'default' preset is recommended,
          -- you will need to read `:help ins-completion`
          --
          -- No, but seriously. Please read `:help ins-completion`, it is really good!
          --
          -- All presets have the following mappings:
          -- <tab>/<s-tab>: move to right/left of your snippet expansion
          -- <c-space>: Open menu or open docs if already open
          -- <c-n>/<c-p> or <up>/<down>: Select next/previous item
          -- <c-e>: Hide menu
          -- <c-k>: Toggle signature help
          preset = 'default',

          -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
          --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
        },
        appearance = {
          nerd_font_variant = 'normal',
        },
        completion = {
          menu = {
            border = 'none',
          },
          list = {
            selection = {
              auto_insert = false,
            },
          },
          documentation = {
            auto_show = false,
            window = { border = 'rounded' },
          },
        },
        sources = {
          default = { 'lsp', 'path', 'snippets', 'lazydev' },
          providers = {
            lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
          },
        },
        snippets = { preset = 'luasnip' },
        fuzzy = { implementation = 'rust' },
        signature = {
          enabled = true,
          trigger = {
            show_on_accept = true,
          },
          window = {
            show_documentation = false,
          },
        },
      }

      vim.lsp.config('*', { capabilities = require('blink.cmp').get_lsp_capabilities() })
    end,
  },
}
