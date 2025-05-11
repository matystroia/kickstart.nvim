--- @type LazyPluginSpec[]
return {
  {
    -- TODO: Lazy load
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      'saghen/blink.cmp',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            local prefix = vim.startswith(keys, 'gr') and '[G]o [R]ef ' or ' '
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. prefix .. desc })
          end

          map('grn', vim.lsp.buf.rename, 'Re[n]ame')
          map('gra', vim.lsp.buf.code_action, '[A]ction', { 'n', 'x' })
          map('grr', require('telescope.builtin').lsp_references, '[R]eferences')
          map('gri', require('telescope.builtin').lsp_implementations, '[I]mplementation')
          map('grd', require('telescope.builtin').lsp_definitions, '[D]efinition')
          map('grD', vim.lsp.buf.declaration, '[D]eclaration')
          map('grt', require('telescope.builtin').lsp_type_definitions, '[T]ype')

          map('gO', require('telescope.builtin').lsp_document_symbols, '[O]pen Symbols')
          map('gW', function()
            require('telescope.builtin').lsp_dynamic_workspace_symbols { path_display = { 'hidden' } }
          end, '[W]orkspace Symbols')

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- Override the default border for floating (LSP) windows
      local _open_floating_preview = vim.lsp.util.open_floating_preview
      ---@diagnostic disable-next-line: duplicate-set-field
      function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
        opts = opts or {}
        opts.border = opts.border or 'rounded'
        return _open_floating_preview(contents, syntax, opts, ...)
      end

      -- Diagnostic
      local diagnostic_cfg = {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        },
        virtual_text = {
          source = 'if_many',
          spacing = 2,
          format = function(diagnostic)
            return diagnostic.message
          end,
        },
      }
      vim.diagnostic.config(diagnostic_cfg)

      vim.keymap.set('n', 'gk', vim.diagnostic.open_float, { desc = 'LSP: Open Diagnostic' })
      vim.keymap.set('n', 'gK', function()
        if vim.diagnostic.config().virtual_lines then
          vim.diagnostic.config(vim.tbl_extend('error', diagnostic_cfg, { virtual_lines = false }))
        else
          vim.diagnostic.config { virtual_text = false, virtual_lines = true }
        end
      end, { desc = 'LSP: Toggle Diagnostic Lines' })

      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      --- @type { [string]: vim.lsp.Config }
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
        basedpyright = {},
        svelte = {},
        tailwindcss = {},
      }

      for server, config in pairs(servers) do
        vim.lsp.config(server, config)
      end

      local ensure_installed = {}
      vim.list_extend(ensure_installed, { 'lua_ls', 'basedpyright', 'bashls', 'cssls', 'hyprls', 'svelte', 'tailwindcss' })
      vim.list_extend(ensure_installed, { 'stylua', 'isort', 'black', 'prettierd', 'shfmt' })

      require('mason-tool-installer').setup { ensure_installed = ensure_installed }
      require('mason-lspconfig').setup {
        ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
        automatic_enable = true,
      }
    end,
  },
  {
    'saghen/blink.cmp',
    event = 'VimEnter',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        version = '2.*',
        build = (function()
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          -- `friendly-snippets` contains a variety of premade snippets.
          --    See the README about individual language/framework/plugin snippets:
          --    https://github.com/rafamadriz/friendly-snippets
          -- {
          --   'rafamadriz/friendly-snippets',
          --   config = function()
          --     require('luasnip.loaders.from_vscode').lazy_load()
          --   end,
          -- },
        },
        opts = {},
      },
      'folke/lazydev.nvim',
    },
    --- @module 'blink.cmp'
    --- @type blink.cmp.Config
    opts = {
      keymap = {
        -- 'default' (recommended) for mappings similar to built-in completions
        --   <c-y> to accept ([y]es) the completion.
        --    This will auto-import if your LSP supports it.
        --    This will expand snippets if the LSP sent a snippet.
        -- 'super-tab' for tab to accept
        -- 'enter' for enter to accept
        -- 'none' for no mappings
        --
        -- For an understanding of why the 'default' preset is recommended,
        -- you will need to read `:help ins-completion`
        --
        -- No, but seriously. Please read `:help ins-completion`, it is really good!
        --
        -- All presets have the following mappings:
        -- <tab>/<s-tab>: move to right/left of your snippet expansion
        -- <c-space>: Open menu or open docs if already open
        -- <c-n>/<c-p> or <up>/<down>: Select next/previous item
        -- <c-e>: Hide menu
        -- <c-k>: Toggle signature help
        --
        -- See :h blink-cmp-config-keymap for defining your own keymap
        preset = 'enter',

        -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
        --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
      },

      appearance = {
        nerd_font_variant = 'normal',
      },

      completion = {
        documentation = {
          auto_show = false,
          window = { border = 'rounded' },
        },
      },

      sources = {
        default = { 'lsp', 'path', 'snippets', 'lazydev' },
        providers = {
          lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
        },
      },

      snippets = { preset = 'luasnip' },

      -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
      -- which automatically downloads a prebuilt binary when enabled.
      --
      -- By default, we use the Lua implementation instead, but you may enable
      -- the rust implementation via `'prefer_rust_with_warning'`
      --
      -- See :h blink-cmp-config-fuzzy for more information
      fuzzy = { implementation = 'lua' },

      -- Shows a signature help window while you type arguments for a function
      signature = { enabled = true },
    },
  },
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = 'lazy.nvim', words = { 'LazyPluginSpec' } },
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
        { path = '$HOME/git/wezterm-types', mods = { 'wezterm' } },
        { path = '/usr/share/lua/5.1/fun.lua', mods = { 'fun' } },
      },
    },
  },
  {
    'pmizio/typescript-tools.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
    opts = {},
  },
}
