---@type PlugSpec
return {
  src = 'https://github.com/mason-org/mason.nvim',
  setup = function ()
    require('mason').setup {}

    -- local installed = vim.iter(require('mason-registry').get_installed_package_names()):fold({},function (acc, pkg)
    --   acc[pkg] = true
    --   return acc
    -- end)
    --
    --
    -- local ensure_installed = {
    --   'bash-language-server', 'clang-format', 'clangd', 'codelldb', 'css-lsp', 'emmylua_ls', 'isort',
    --   'jsonlint', 'prettierd', 'qmlls', 'rust-analyzer', 'shfmt', 'stylua', 'svelte-language-server',
    --   'tailwindcss-language-server'
    -- }
    --
    -- local to_install = vim.iter(ensure_installed):filter(function (pkg) return not installed[pkg] end):totable()
    -- if #to_install > 0 then
    --   vim.ui.input({prompt=#to_install .. 'missing packages. Install? (y/N): ', scope='editor'}, function(input)
    --     if input == 'y' or input == 'yes' then
    --   vim.cmd('MasonInstall ' .. vim.iter(to_install):join(' '))
    --     end
    --   end)
    -- end
  end
}
