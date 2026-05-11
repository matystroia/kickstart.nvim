---@type LazyPluginSpec
return {
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
}
