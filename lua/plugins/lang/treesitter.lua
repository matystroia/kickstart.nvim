--- @type (LazyPluginSpec | string)[]
return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    opts = {
      ensure_installed = {
        'bash',
        'c',
        'diff',
        'html',
        'hyprlang',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'python',
        'query',
        'vim',
        'vimdoc',
      },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true, disable = { 'ruby' } },
    },
    init = function()
      vim.filetype.add {
        pattern = {
          ['.*/hypr/.*%.conf'] = 'hyprlang',
        },
      }
    end,
    -- There are additional nvim-treesitter modules that you can use to interact
    -- with nvim-treesitter. You should go explore a few and see what interests you:
    --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
    --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
    opts = { mode = 'cursor', max_lines = 2, trim_scope = 'outer' },
  },
  {
    'elkowar/yuck.vim',
    ft = 'yuck',
    dependencies = {
      { 'eraserhd/parinfer-rust', build = 'cargo build --release' },
    },
  },
  {
    'tridactyl/vim-tridactyl',
    ft = 'tridactyl',
  },
}
