---@type PlugSpec
return {
  src = 'https://github.com/nvim-treesitter/nvim-treesitter-textobjects',
  setup = function()
    vim.g.no_plugin_maps = true

    require('nvim-treesitter-textobjects').setup {
      select = {
        lookahead = true,
      },
      move = {
        set_jumps = false,
      },
    }

    local select = require('nvim-treesitter-textobjects.select').select_textobject

    vim.keymap.set({ 'x', 'o' }, 'if', function() select('@function.inner', 'textobjects') end)
    vim.keymap.set({ 'x', 'o' }, 'af', function() select('@function.outer', 'textobjects') end)

    vim.keymap.set({ 'x', 'o' }, 'iC', function() select('@class.inner', 'textobjects') end)
    vim.keymap.set({ 'x', 'o' }, 'aC', function() select('@class.outer', 'textobjects') end)

    vim.keymap.set({ 'x', 'o' }, 'ic', function() select('@call.inner', 'textobjects') end)
    vim.keymap.set({ 'x', 'o' }, 'ac', function() select('@call.outer', 'textobjects') end)

    vim.keymap.set({ 'x', 'o' }, 'il', function() select('@assignment.lhs', 'textobjects') end)
    vim.keymap.set({ 'x', 'o' }, 'ir', function() select('@assignment.rhs', 'textobjects') end)

    vim.keymap.set({ 'x', 'o' }, 'ia', function() select('@parameter.inner', 'textobjects') end)
    vim.keymap.set({ 'x', 'o' }, 'aa', function() select('@parameter.outer', 'textobjects') end)

    vim.keymap.set({ 'x', 'o' }, 'as', function() select('@statement.outer', 'textobjects') end)

    vim.keymap.set({ 'x', 'o' }, ']n', function() vim.treesitter.select('extend_next', 1) end)

    vim.keymap.set({ 'x', 'o' }, '[n', function() vim.treesitter.select('extend_prev', 1) end)

    local move = require 'nvim-treesitter-textobjects.move'
    local goto_next_start = move.goto_next_start
    local goto_next_end = move.goto_next_end
    local goto_prev_start = move.goto_previous_start
    local goto_prev_end = move.goto_previous_end

    vim.keymap.set({ 'n', 'x', 'o' }, ']f', function() goto_next_start('@function.outer', 'textobjects') end)
    vim.keymap.set({ 'n', 'x', 'o' }, ']F', function() goto_next_end('@function.outer', 'textobjects') end)
    vim.keymap.set({ 'n', 'x', 'o' }, '[f', function() goto_prev_start('@function.outer', 'textobjects') end)
    vim.keymap.set({ 'n', 'x', 'o' }, '[F', function() goto_prev_end('@function.outer', 'textobjects') end)

    vim.keymap.set({ 'n', 'x', 'o' }, ']s', function() goto_next_start('@statement.outer', 'textobjects') end)
    vim.keymap.set({ 'n', 'x', 'o' }, ']S', function() goto_next_end('@statement.outer', 'textobjects') end)
    vim.keymap.set({ 'n', 'x', 'o' }, '[s', function() goto_prev_start('@statement.outer', 'textobjects') end)
    vim.keymap.set({ 'n', 'x', 'o' }, '[S', function() goto_prev_end('@statement.outer', 'textobjects') end)

    vim.keymap.set({ 'n', 'x', 'o' }, ']C', function() goto_next_start('@class.outer', 'textobjects') end)
    vim.keymap.set({ 'n', 'x', 'o' }, '[C', function() goto_prev_start('@class.outer', 'textobjects') end)

    vim.keymap.set({ 'n', 'x', 'o' }, ']a', function() goto_next_start('@parameter.inner', 'textobjects') end)
    vim.keymap.set({ 'n', 'x', 'o' }, '[a', function() goto_prev_start('@parameter.inner', 'textobjects') end)

    -- TODO: Move all of this to somewhere more generic, create own repeat_move
    local repeat_move = require 'nvim-treesitter-textobjects.repeatable_move'
    local leap = require 'leap'

    vim.keymap.set({ 'n', 'x', 'o' }, ';', repeat_move.repeat_last_move)
    vim.keymap.set({ 'n', 'x', 'o' }, ',', repeat_move.repeat_last_move_opposite)

    vim.api.nvim_create_autocmd('User', {
      pattern = 'LeapLeave',
      callback = function()
        local forward = leap.state['repeat'].backward ~= true
        repeat_move.last_move = {
          func = function(opts) leap.leap { ['repeat'] = true, backward = not opts.forward } end,
          opts = { forward = forward },
          additional_args = {},
        }
      end,
    })

    vim.iter({ 'f', 'F', 't', 'T' }):each(function(op)
      local forward = op ~= op:upper()
      vim.keymap.set({ 'n', 'x', 'o' }, op, function()
        repeat_move.last_move = {
          func = op,
          opts = { forward = forward },
          additional_args = {},
        }
        return op
      end, { expr = true })
    end)

    local select_node = repeat_move.make_repeatable_move(function(opts)
      if opts.forward then
        vim.treesitter.select 'parent'
      else
        vim.treesitter.select 'child'
      end
    end)

    vim.keymap.set('x', 'an', function()
      repeat_move.last_move = {
        func = select_node,
        opts = { forward = true },
        additional_args = {},
      }
      vim.treesitter.select 'parent'
    end)

    vim.keymap.set('x', 'in', function()
      repeat_move.last_move = {
        func = select_node,
        opts = { forward = false },
        additional_args = {},
      }
      vim.treesitter.select 'child'
    end)
  end,
}
