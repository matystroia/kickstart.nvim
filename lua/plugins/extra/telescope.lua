local function prefix_find_files(opts)
  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local make_entry = require 'telescope.make_entry'
  local conf = require('telescope.config').values

  opts = opts or {}
  opts.cwd = opts.cwd or vim.uv.cwd()
  opts.filetype = opts.filetype or 'f'
  opts.path_display = {
    filename_first = {
      reverse_directories = true,
    },
  }

  pickers
    .new(opts, {
      finder = finders.new_oneshot_job({ 'fd', '--color', 'never', '-p', '--type', opts.filetype }, {
        entry_maker = opts.entry_maker or make_entry.gen_from_file(opts),
        cwd = opts.cwd,
      }),
      previewer = conf.grep_previewer(opts),
      sorter = conf.file_sorter(opts),
      on_input_filter_cb = function(prompt)
        local prefix = prompt:match '(([%.%~%/])%2)'
        if prefix then
          local cwd
          if prefix == '..' then
            cwd = vim.uv.cwd()
          elseif prefix == '~~' then
            cwd = vim.fn.getenv 'HOME'
          elseif prefix == '//' then
            cwd = '/'
          end
          vim.schedule(function()
            prefix_find_files(vim.tbl_extend('force', opts, {
              cwd = cwd,
              default_text = prompt:gsub('[%.%~%/]', ''),
              prompt_title = ({ ['.'] = 'Current Dir', ['~'] = 'Home', ['/'] = 'Root' })[prefix],
            }))
          end)
          return nil
        end
      end,
    })
    :find()
end

--- @type LazyPluginSpec[]
return {
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-tree/nvim-web-devicons' },
    },
    config = function()
      require('telescope').setup {
        defaults = {
          prompt_prefix = '',
          selection_caret = ' ',
          mappings = {
            n = {
              ['\\'] = require('telescope.actions').select_vertical,
              ['|'] = require('telescope.actions').select_horizontal,
              ['<C-v>'] = require('telescope.actions.layout').toggle_preview,
            },
            i = {
              ['<C-v>'] = require('telescope.actions.layout').toggle_preview,
            },
          },
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      require('telescope').load_extension 'fzf'
      require('telescope').load_extension 'ui-select'

      local builtin = require 'telescope.builtin'
      local themes = require 'telescope.themes'

      vim.keymap.set('n', '<Leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<Leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<Leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<Leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<Leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<Leader>so', builtin.oldfiles, { desc = '[S]earch [O]ld' })

      vim.keymap.set('n', '<Leader>sp', function()
        builtin.find_files { cwd = vim.fs.joinpath(vim.fn.stdpath 'data', 'lazy') }
      end, { desc = '[S]earch [P]ackages' })

      vim.keymap.set('n', '<Leader>s/', function()
        builtin.current_buffer_fuzzy_find(themes.get_dropdown { previewer = false })
      end, { desc = '[S]earch buffer' })

      vim.keymap.set('n', '<Tab><Tab>', builtin.buffers, { desc = 'Find buffers' })

      vim.keymap.set('n', '<C-p>', function()
        prefix_find_files(themes.get_dropdown { previewer = false, prompt_title = 'Find' })
      end)
    end,
  },
}
