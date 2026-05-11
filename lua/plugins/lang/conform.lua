---@type PlugSpec
return {
  src = 'https://github.com/stevearc/conform.nvim',
  setup = function()
    -- TODO: Ensure installed
    local conform = require 'conform'

    ---@type table<string, conform.FiletypeFormatterInternal>
    local formatters_by_ft = {
      lua = { 'stylua' },
      python = { 'ruff_format', 'isort' },
      sh = { 'shfmt' },
      -- TODO: Enable this when it stops sucking
      -- nu = { 'nufmt' },
    }
    ---@type table<string, string[]>
    local general_formatters = {
      prettierd = { 'javascript', 'typescript', 'json', 'jsonc', 'html', 'javascriptreact', 'typescriptreact' },
    }

    formatters_by_ft = vim.tbl_extend(
      'error',
      formatters_by_ft,
      vim.iter(pairs(general_formatters)):fold({}, function(acc, fmt, fts)
        vim.iter(fts):each(function(ft)
          acc[ft] = { fmt }
        end)
        return acc
      end)
    )

    conform.setup {
      notify_on_error = false,
      format_on_save = function(bufnr)
        if vim.b[bufnr].conform_disabled then
          return nil
        end
        return {
          timeout_ms = 1500,
          lsp_format = 'fallback',
        }
      end,
      formatters_by_ft = formatters_by_ft,
      formatters = {
        stylua = {
          -- Use Neovim .stylua for random lua files
          -- prepend_args = { '--config-path', vim.fn.stdpath 'config' .. '/.stylua.toml' },
        },
      },
    }

    vim.keymap.set('n', '<Leader>f', function()
      conform.format { async = true, lsp_format = 'fallback' }
    end, { desc = '[F]ormat buffer' })

    vim.keymap.set('n', '<Leader>tf', function()
      if vim.b.conform_disabled then
        vim.b.conform_disabled = false
        vim.notify('[Conform] Enabled', vim.log.levels.INFO)
      else
        vim.b.conform_disabled = true
        vim.notify('[Conform] Disabled', vim.log.levels.INFO)
      end
    end, { desc = '[T]oggle [F]ormat' })
  end,
}
