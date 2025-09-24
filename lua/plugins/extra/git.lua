---@type (LazyPluginSpec | string)[]
return {
  { 'tpope/vim-fugitive' },
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      sign_priority = 1000,
      on_attach = function(bufnr)
        local gitsigns = require 'gitsigns'

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal { ']c', bang = true }
          else
            gitsigns.nav_hunk('next', { wrap = false, navigation_message = true, preview = true })
          end
        end, { desc = 'Next [C]hange' })

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal { '[c', bang = true }
          else
            gitsigns.nav_hunk('prev', { wrap = false, navigation_message = true, preview = true })
          end
        end, { desc = 'Previous [C]hange' })

        map('v', '<Leader>hs', function()
          gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = '[G]it [S]tage Hunk' })
        map('v', '<Leader>hr', function()
          gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = '[G]it [R]eset Hunk' })

        map('n', '<Leader>hs', gitsigns.stage_hunk, { desc = '[H]unk [S]tage' })
        map('n', '<Leader>hr', gitsigns.reset_hunk, { desc = '[H]unk [R]eset' })
        map('n', '<Leader>hp', gitsigns.preview_hunk_inline, { desc = '[H]unk [P]review' })

        map('n', '<Leader>hS', gitsigns.stage_buffer, { desc = '[H]unk [S]tage Buffer' })
        map('n', '<Leader>hR', gitsigns.reset_buffer, { desc = '[H]unk [R]eset Buffer' })

        map('n', '<Leader>gb', gitsigns.blame_line, { desc = '[G]it [B]lame' })
        map('n', '<Leader>gB', gitsigns.blame, { desc = '[G]it [B]lame All' })
        map('n', '<Leader>gd', gitsigns.diffthis, { desc = '[G]it [D]iff Index' })

        map('n', '<Leader>gD', function()
          gitsigns.diffthis '@'
        end, { desc = '[G]it [D]iff Last Commit' })

        map('n', '<Leader>tb', gitsigns.toggle_current_line_blame, { desc = '[T]oggle [B]lame' })
      end,
    },
  },
}
