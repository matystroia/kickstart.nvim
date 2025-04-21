---@type (LazyPluginSpec | string)[]
return {
  {
    'github/copilot.vim',
    config = function()
      vim.keymap.set('i', '<C-y>', 'copilot#Accept("")', {
        expr = true,
        replace_keycodes = false,
      })
      vim.g.copilot_no_tab_map = true

      local timer, err = vim.uv.new_timer()
      if timer == nil then
        vim.notify('Timer error: ' .. err, vim.log.levels.ERROR)
        return
      end

      local function check_context()
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        row, col = row - 1, math.max(0, col - 1) -- Just left of cursor
        for _, capture in ipairs(vim.treesitter.get_captures_at_pos(0, row, col)) do
          if capture.capture == 'comment' then
            vim.b.copilot_enabled = false
            return
          end
        end
        vim.b.copilot_enabled = nil
      end

      local group = vim.api.nvim_create_augroup('copilot-shutup', { clear = true })
      vim.api.nvim_create_autocmd('BufEnter', {
        group = group,
        callback = function()
          if vim.b.has_treesitter ~= nil then
            return
          end
          local is_file_buf = vim.bo.filetype ~= '' and vim.bo.buftype == ''
          vim.b.has_treesitter = is_file_buf and vim.treesitter.get_parser(nil, nil, { error = false }) ~= nil
        end,
      })
      vim.api.nvim_create_autocmd('InsertEnter', {
        group = group,
        callback = function()
          if not vim.b.has_treesitter then
            return
          end
          timer:start(0, 500, vim.schedule_wrap(check_context))
        end,
      })
      vim.api.nvim_create_autocmd({ 'BufLeave', 'InsertLeave' }, {
        group = group,
        callback = function()
          timer:stop()
        end,
      })
      vim.api.nvim_create_autocmd('VimLeavePre', {
        group = group,
        callback = function()
          timer:close()
        end,
      })
    end,
  },
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    dependencies = {
      { 'github/copilot.vim' },
      { 'nvim-lua/plenary.nvim', branch = 'master' },
    },
    opts = {},
    keys = {
      {
        '<leader>cc',
        function()
          require('CopilotChat').open()
        end,
        desc = 'Open Copilot Chat',
      },
    },
    build = 'make tiktoken',
  },
}
