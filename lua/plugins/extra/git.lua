---@type (LazyPluginSpec | string)[]
return {
  'tpope/vim-fugitive',
  {
    'lewis6991/gitsigns.nvim',
    opts = {
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
            gitsigns.nav_hunk 'next'
          end
        end, { desc = 'Jump to next git [c]hange' })

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal { '[c', bang = true }
          else
            gitsigns.nav_hunk 'prev'
          end
        end, { desc = 'Jump to previous git [c]hange' })

        map('v', '<leader>hs', function()
          gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'git [s]tage hunk' })
        map('v', '<leader>hr', function()
          gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = '[G]it [R]eset Hunk' })

        map('n', '<Leader>gs', gitsigns.stage_hunk, { desc = '[G]it [S]tage Hunk' })
        map('n', '<Leader>gr', gitsigns.reset_hunk, { desc = '[G]it [R]eset Hunk' })
        map('n', '<Leader>gp', gitsigns.preview_hunk, { desc = '[G]it [P]review Hunk' })

        map('n', '<Leader>gS', gitsigns.stage_buffer, { desc = '[G]it [S]tage Buffer' })
        map('n', '<Leader>gR', gitsigns.reset_buffer, { desc = '[G]it [R]eset Buffer' })

        map('n', '<Leader>gb', gitsigns.blame_line, { desc = '[G]it [B]lame' })
        map('n', '<Leader>gd', gitsigns.diffthis, { desc = '[G]it [D]iff Index' })

        map('n', '<Leader>gD', function()
          gitsigns.diffthis '@'
        end, { desc = 'git [D]iff against last commit' })

        map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = '[T]oggle git show [b]lame line' })
        map('n', '<leader>tD', gitsigns.preview_hunk_inline, { desc = '[T]oggle git show [D]eleted' })
      end,
    },
  },
}
