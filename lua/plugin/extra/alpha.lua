---@type PlugSpec
return {
  src = 'https://github.com/goolord/alpha-nvim',
  setup = function()
    local alpha = require 'alpha'
    local dashboard = require 'alpha.themes.dashboard'

    local art_path = vim.fs.joinpath(vim.fn.stdpath 'config', 'assets', 'strigoi.txt')
    dashboard.section.header.val = vim.fn.readfile(art_path)

    local version = vim.version()
    local version_str = string.format('v%d.%d.%d (%s)', version.major, version.minor, version.patch, version.build)
    dashboard.section.footer.val = version_str

    dashboard.section.buttons.val = {
      dashboard.button('e', '  New', ':ene | startinsert <CR>'),
      dashboard.button(
        'c',
        '  Config',
        ':lua require("telescope.builtin").find_files({cwd = vim.env.XDG_CONFIG_HOME})<CR>'
      ),
      dashboard.button('u', '  Update', ':lua vim.pack.update()<CR>'),
      dashboard.button('q', '  Quit', ':q<CR>'),
      -- TODO: Sessions and MRU
    }

    alpha.setup(dashboard.config)
  end,
}
