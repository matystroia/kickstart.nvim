--- @type LazyPluginSpec[]
return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    init = function()
      -- TODO: ensure_installed

      vim.api.nvim_create_autocmd('FileType', {
        callback = function(ev)
          local lang = vim.treesitter.language.get_lang(ev.match)
          if not lang then
            return
          end

          if not vim.treesitter.language.add(lang) then
            return
          end

          vim.treesitter.start(ev.buf, lang)

          if vim.treesitter.query.get(lang, 'indents') then
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })

      vim.filetype.add {
        pattern = {
          ['.*/hypr/.*%.conf'] = 'hyprlang',
        },
      }
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'jinh0/eyeliner.nvim', { url = 'https://codeberg.org/andyg/leap.nvim' } },
    init = function()
      vim.g.no_plugin_maps = true
    end,
    config = function()
      require('nvim-treesitter-textobjects').setup {
        select = {
          lookahead = true,
        },
        move = {
          set_jumps = false,
        },
      }

      local select = require('nvim-treesitter-textobjects.select').select_textobject

      vim.keymap.set({ 'x', 'o' }, 'if', function()
        select('@function.inner', 'textobjects')
      end)
      vim.keymap.set({ 'x', 'o' }, 'af', function()
        select('@function.outer', 'textobjects')
      end)

      vim.keymap.set({ 'x', 'o' }, 'iC', function()
        select('@class.inner', 'textobjects')
      end)
      vim.keymap.set({ 'x', 'o' }, 'aC', function()
        select('@class.outer', 'textobjects')
      end)

      vim.keymap.set({ 'x', 'o' }, 'ic', function()
        select('@call.inner', 'textobjects')
      end)
      vim.keymap.set({ 'x', 'o' }, 'ac', function()
        select('@call.outer', 'textobjects')
      end)

      vim.keymap.set({ 'x', 'o' }, 'al', function()
        select('@assignment.lhs', 'textobjects')
      end)
      vim.keymap.set({ 'x', 'o' }, 'ar', function()
        select('@assignment.rhs', 'textobjects')
      end)

      vim.keymap.set({ 'x', 'o' }, 'ia', function()
        select('@parameter.inner', 'textobjects')
      end)
      vim.keymap.set({ 'x', 'o' }, 'aa', function()
        select('@parameter.outer', 'textobjects')
      end)

      vim.keymap.set({ 'x', 'o' }, 'as', function()
        select('@statement.outer', 'textobjects')
      end)

      vim.keymap.set({ 'x', 'o' }, ']n', function()
        vim.treesitter.select('extend_next', 1)
      end)

      vim.keymap.set({ 'x', 'o' }, '[n', function()
        vim.treesitter.select('extend_prev', 1)
      end)

      local goto_next_start = require('nvim-treesitter-textobjects.move').goto_next_start
      local goto_next_end = require('nvim-treesitter-textobjects.move').goto_next_end
      local goto_prev_start = require('nvim-treesitter-textobjects.move').goto_previous_start
      local goto_prev_end = require('nvim-treesitter-textobjects.move').goto_previous_end

      vim.keymap.set({ 'n', 'x', 'o' }, ']f', function()
        goto_next_start('@function.outer', 'textobjects')
      end)
      vim.keymap.set({ 'n', 'x', 'o' }, ']F', function()
        goto_next_end('@function.outer', 'textobjects')
      end)
      vim.keymap.set({ 'n', 'x', 'o' }, '[f', function()
        goto_prev_start('@function.outer', 'textobjects')
      end)
      vim.keymap.set({ 'n', 'x', 'o' }, '[F', function()
        goto_prev_end('@function.outer', 'textobjects')
      end)

      vim.keymap.set({ 'n', 'x', 'o' }, ']s', function()
        goto_next_start('@statement.outer', 'textobjects')
      end)
      vim.keymap.set({ 'n', 'x', 'o' }, ']S', function()
        goto_next_end('@statement.outer', 'textobjects')
      end)
      vim.keymap.set({ 'n', 'x', 'o' }, '[s', function()
        goto_prev_start('@statement.outer', 'textobjects')
      end)
      vim.keymap.set({ 'n', 'x', 'o' }, '[S', function()
        goto_prev_end('@statement.outer', 'textobjects')
      end)

      vim.keymap.set({ 'n', 'x', 'o' }, ']C', function()
        goto_next_start('@class.outer', 'textobjects')
      end)
      vim.keymap.set({ 'n', 'x', 'o' }, '[C', function()
        goto_prev_start('@class.outer', 'textobjects')
      end)

      vim.keymap.set({ 'n', 'x', 'o' }, ']a', function()
        goto_next_start('@parameter.inner', 'textobjects')
      end)
      vim.keymap.set({ 'n', 'x', 'o' }, '[a', function()
        goto_prev_start('@parameter.inner', 'textobjects')
      end)

      -- TODO: Move all of this to somewhere more generic, create own repeat_move
      local repeat_move = require 'nvim-treesitter-textobjects.repeatable_move'
      local eyeliner = require 'eyeliner'
      local leap = require 'leap'

      vim.keymap.set({ 'n', 'x', 'o' }, ';', repeat_move.repeat_last_move)
      vim.keymap.set({ 'n', 'x', 'o' }, ',', repeat_move.repeat_last_move_opposite)

      vim.api.nvim_create_autocmd('User', {
        pattern = 'LeapLeave',
        callback = function()
          local forward = leap.state['repeat'].backward ~= true
          repeat_move.last_move = {
            func = function(opts)
              leap.leap { ['repeat'] = true, backward = not opts.forward }
            end,
            opts = { forward = forward },
            additional_args = {},
          }
        end,
      })

      vim.iter({ 'f', 'F', 't', 'T' }):each(function(op)
        local forward = op ~= op:upper()
        vim.keymap.set({ 'n', 'x', 'o' }, op, function()
          eyeliner.highlight { forward = forward }
          repeat_move.last_move = {
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
