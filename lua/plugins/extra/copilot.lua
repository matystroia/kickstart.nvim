---@type (LazyPluginSpec | string)[]
return {
  {
    'zbirenbaum/copilot.lua',
    event = 'InsertEnter',
    config = function()
      local copilot = require 'copilot'
      local suggestion = require 'copilot.suggestion'

      copilot.setup {
        panel = { enabled = false },
        suggestion = {
          auto_trigger = false,
          keymap = {
            accept = false,
            accept_word = false,
            accept_line = false,
            next = '<M-]>',
            prev = '<M-[>',
            dismiss = '<C-]>',
          },
        },
        copilot_model = 'gpt-4o-copilot',
      }

      vim.keymap.set('i', '<M-l>', function()
        if suggestion.is_visible() then
          suggestion.accept()
        else
          return '<Right>'
        end
      end, { expr = true })

      vim.keymap.set('n', '<Leader>tc', function()
        if vim.b.copilot_suggestion_auto_trigger then
          suggestion.toggle_auto_trigger()
          vim.notify('[Copilot] Disabled :)', vim.log.levels.INFO)
        else
          suggestion.toggle_auto_trigger()
          vim.notify('[Copilot] Enabled', vim.log.levels.INFO)
        end
      end, { desc = 'Toggle Copilot' })

      -- Disable copilot suggestions while autocomplete menu is visible
      local blink_group = vim.api.nvim_create_augroup('copilot-disable-blink', { clear = true })
      vim.api.nvim_create_autocmd('User', {
        pattern = 'BlinkCmpMenuOpen',
        group = blink_group,
        callback = function()
          vim.b.copilot_suggestion_hidden = true
        end,
      })
      vim.api.nvim_create_autocmd('User', {
        pattern = 'BlinkCmpMenuClose',
        group = blink_group,
        callback = function()
          vim.b.copilot_suggestion_hidden = false
        end,
      })

      local timer, err = vim.uv.new_timer()
      if timer == nil then
        vim.notify('Timer error: ' .. err, vim.log.levels.ERROR)
        return
      end

      local function check_context()
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        row, col = row - 1, math.max(0, col - 1) -- Just left of cursor
        local is_comment = vim.iter(vim.treesitter.get_captures_at_pos(0, row, col)):any(function(cap)
          return cap.capture == 'comment'
        end)
        vim.b.copilot_suggestion_hidden = is_comment
      end

      -- Disable copilot suggestions in comments
      local comment_group = vim.api.nvim_create_augroup('copilot-disable-comments', { clear = true })
      vim.api.nvim_create_autocmd('BufEnter', {
        group = comment_group,
        callback = function()
          vim.b.has_treesitter = vim.bo.filetype ~= '' and vim.treesitter.get_parser(nil, nil, { error = false }) ~= nil
        end,
      })
      vim.api.nvim_create_autocmd('InsertEnter', {
        group = comment_group,
        callback = function()
          if vim.b.has_treesitter then
            timer:start(0, 500, vim.schedule_wrap(check_context))
          end
        end,
      })
      vim.api.nvim_create_autocmd({ 'BufLeave', 'InsertLeave' }, {
        group = comment_group,
        callback = function()
          timer:stop()
        end,
      })
      vim.api.nvim_create_autocmd('VimLeavePre', {
        group = comment_group,
        callback = function()
          timer:close()
        end,
      })
    end,
  },
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    dependencies = {
      { 'zbirenbaum/copilot.lua' },
      { 'nvim-lua/plenary.nvim', branch = 'master' },
    },
    opts = {
      mappings = {
        submit_prompt = {
          normal = '<CR>',
          insert = '<C-CR>',
        },
      },
    },
    keys = {
      {
        '<Leader>cc',
        function()
          require('CopilotChat').open()
        end,
        desc = 'Open Copilot Chat',
      },
    },
    build = 'make tiktoken',
  },
}
