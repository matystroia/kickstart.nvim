--- @type (LazyPluginSpec | string)[]
return {
  { 'NMAC427/guess-indent.nvim', opts = {} },
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    config = function()
      local formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'isort', 'black' },
        sh = { 'shfmt' },
      }
      local general_formatters = {
        prettierd = { 'javascript', 'typescript', 'json', 'jsonc', 'html' },
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

      vim.keymap.set('n', '<Leader>tf', function()
        if vim.b.conform_disabled then
          vim.b.conform_disabled = false
          vim.notify('[Conform] Enabled', vim.log.levels.INFO)
        else
          vim.b.conform_disabled = true
          vim.notify('[Conform] Disabled', vim.log.levels.INFO)
        end
      end)

      require('conform').setup {
        notify_on_error = true,
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
            -- Use nvim stylua config for all lua files
            prepend_args = { '--config-path', vim.fn.stdpath 'config' .. '/.stylua.toml' },
          },
        },
      }
    end,
  },
}
