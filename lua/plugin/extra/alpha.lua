--- TODO: Check git -> new master commits

---@type PlugSpec
return {
  src = 'https://github.com/goolord/alpha-nvim',
  setup = function(opts)
    local alpha = require 'alpha'
    local dashboard = require 'alpha.themes.dashboard'
    local sections = {}

    local art_path = vim.fs.joinpath(vim.fn.stdpath 'config', 'assets', 'strigoi.txt')
    sections.header = {
      type = 'text',
      val = vim.split(io.open(art_path):read '*a', '\n'),
      opts = {
        position = 'center',
      },
    }

    local fortune = vim.system({ 'fortune', '-a' }, { text = true }):wait().stdout
    sections.fortune = {
      type = 'text',
      val = vim.split(fortune, '\n'),
      opts = {
        position = 'center',
        hl = 'String',
      },
    }

    sections.buttons = {
      type = 'group',
      val = {
        dashboard.button('e', '  New', ':ene | startinsert <CR>'),
        dashboard.button(
          'c',
          '  Config',
          ':lua require("telescope.builtin").find_files({cwd = vim.env.XDG_CONFIG_HOME})<CR>'
        ),
        dashboard.button('u', '  Update', ':lua vim.pack.update()<CR>'),
        dashboard.button('q', '  Quit', ':q<CR>'),
        -- TODO: Sessions and MRU
      },
      opts = {
        spacing = 1,
      },
    }

    alpha.setup {
      layout = {
        sections.header,
        sections.buttons,
        sections.fortune,
      },
    }
  end,
}
