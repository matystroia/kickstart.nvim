---@type PlugSpec
return {
  src = 'https://github.com/nvim-treesitter/nvim-treesitter',
  build = function()
    vim.cmd 'TSUpdate'
  end,
  setup = function()
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
