-- TODO: Figure this out

---@type PlugSpec
return {
  src = 'https://github.com/nvim-neorg/neorg',
  enabled = false,
  setup = function()
    require('neorg').setup {
      load = {
        ['core.defaults'] = {},
        ['core.concealer'] = {},
        ['core.dirman'] = {
          config = {
            workspaces = {
              notes = '~/notes',
            },
            default_workspace = 'notes',
          },
        },
      },
    }
  end,
}
