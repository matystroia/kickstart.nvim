--- @type (LazyPluginSpec | string)[]
return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    opts = {
      ensure_installed = {
        'bash',
        'c',
        'diff',
        'html',
        'hyprlang',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'python',
        'query',
        'vim',
        'vimdoc',
      },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true, disable = { 'ruby' } },
      incremental_selection = {
        enable = true,
        keymaps = {
          node_incremental = '>',
          node_decremental = '<',
        },
      },
    },
    init = function()
      vim.filetype.add {
        pattern = {
          ['.*/hypr/.*%.conf'] = 'hyprlang',
        },
      }
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'jinh0/eyeliner.nvim', 'ggandor/leap.nvim' },
    config = function()
      require('nvim-treesitter.configs').setup {
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ['if'] = '@function.inner',
              ['af'] = '@function.outer',

              ['iC'] = '@class.inner',
              ['aC'] = '@class.outer',

              ['as'] = '@statement.outer',

              ['ic'] = '@call.inner',
              ['ac'] = '@call.outer',

              ['al'] = '@assignment.lhs',
              ['ar'] = '@assignment.rhs',

              ['ia'] = '@parameter.inner',
              ['aa'] = '@parameter.outer',
            },
          },
          move = {
            enable = true,
            set_jumps = false,
            goto_next_start = {
              [']f'] = '@function.outer',
              [']s'] = '@statement.outer',
              [']p'] = '@parameter.inner',
              [']C'] = '@class.outer',
            },
            goto_next_end = {
              [']F'] = '@function.outer',
              [']S'] = '@statement.outer',
            },
            goto_previous_start = {
              ['[f'] = '@function.outer',
              ['[s'] = '@statement.outer',
              ['[p'] = '@parameter.inner',
              ['[C'] = '@class.outer',
            },
            goto_previous_end = {
              ['[F'] = '@function.outer',
              ['[S'] = '@statement.outer',
            },
          },
        },
      }
      -- TODO: Move all of this to somewhere more generic, create own repeat_move
      local ts_repeat_move = require 'nvim-treesitter.textobjects.repeatable_move'
      local eyeliner = require 'eyeliner'
      local leap = require 'leap'

      vim.keymap.set({ 'n', 'x', 'o' }, ';', ts_repeat_move.repeat_last_move)
      vim.keymap.set({ 'n', 'x', 'o' }, ',', ts_repeat_move.repeat_last_move_opposite)

      vim.api.nvim_create_autocmd('User', {
        pattern = 'LeapLeave',
        callback = function()
          local forward = leap.state['repeat'].backward ~= true
          ts_repeat_move.set_last_move(function(opts)
            leap.leap { ['repeat'] = true, backward = not opts.forward }
          end, { forward = forward })
        end,
      })

      vim.iter({ 'f', 'F', 't', 'T' }):each(function(op)
        local forward = op ~= op:upper()
        vim.keymap.set({ 'n', 'x', 'o' }, op, function()
          eyeliner.highlight { forward = forward }
          ts_repeat_move.last_move = {
            func = op,
            opts = { forward = forward },
            additional_args = {},
          }
          return op
        end, { expr = true })
      end)
    end,
  },
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
