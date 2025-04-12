--- @type LazyPluginSpec[]
return {
  {
    'jinh0/eyeliner.nvim',
    config = function()
      local eyeliner = require 'eyeliner'
      eyeliner.setup {
        highlight_on_key = true,
        dim = true,
      }

      vim.keymap.set({ 'n', 'x', 'o' }, 'f', function()
        eyeliner.highlight { forward = true }
        return '<Plug>(clever-f-f)'
      end, { expr = true })

      vim.api.nvim_set_hl(0, 'EyelinerSecondary', { fg = '#00ff00', bold = true })
      vim.api.nvim_set_hl(0, 'EyelinerPrimary', { fg = '#ff0000', bold = true })
    end,
    enabled = false,
  },
  {
    'ggandor/leap.nvim',
    config = function()
      local leap = require 'leap'
      vim.keymap.set({ 'n', 'x', 'o' }, 's', '<Plug>(leap)')

      local function iter_matches(str, substr, left, right)
        local i = left
        return function()
          local le, ri = str:find(substr, i, true)
          if le == nil or (right ~= nil and ri > right) then
            return nil
          end
          i = le + 1
          return le
        end
      end

      local function get_line_targets(reverse)
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        col = col + 1 -- (1,0) -> (1,1)

        local line = vim.api.nvim_get_current_line()

        local char1 = vim.fn.getcharstr()
        if not char1:match '^%a$' then
          return char1
        end
        local chars = char1 .. vim.fn.getcharstr()

        local left, right
        if reverse then
          left, right = 1, col - 1
        else
          left, right = col + 1, nil
        end

        local iter = vim.iter(iter_matches(line, chars, left, right)):map(function(i)
          return { pos = { row, i } }
        end)
        if reverse then
          iter = vim.iter(iter:totable()):rev()
        end
        return iter:totable()
      end

      vim.keymap.set({ 'n', 'x', 'o' }, 'f', function()
        local targets = get_line_targets()
        if type(targets) == 'string' then
          vim.api.nvim_feedkeys('f' .. targets, vim.api.nvim_get_mode().mode, false)
          return
        end
        leap.leap {
          target_windows = { vim.api.nvim_get_current_win() },
          targets = targets,
        }
      end)
      vim.keymap.set({ 'n', 'x', 'o' }, 'F', function()
        local targets = get_line_targets(true)
        if type(targets) == 'string' then
          vim.api.nvim_feedkeys('F' .. targets, vim.api.nvim_get_mode().mode, false)
          return
        end
        leap.leap {
          target_windows = { vim.api.nvim_get_current_win() },
          targets = get_line_targets(true),
        }
      end)
      -- TODO: timeout after first key press in case I forget I have to type another
      -- TODO: t/T
    end,
  },
  {
    'rhysd/clever-f.vim',
    init = function()
      vim.g.clever_f_across_no_line = 1
      vim.g.clever_f_not_overwrites_standard_mappings = 1
    end,
    enabled = false,
  },
  -- TODO: Look at all mini.nvim plugins
  {
    'echasnovski/mini.ai',
    opts = { n_lines = 500 },
  },
  {
    'echasnovski/mini.surround',
    opts = {},
  },
}
