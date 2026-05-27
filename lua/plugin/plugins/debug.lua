---@type LazyPluginSpec
return {
  src = 'https://github.com/mfussenegger/nvim-dap',
  enabled = false,
  deps = {
    { src = 'https://github.com/rcarriga/nvim-dap-ui' },
    { src = 'https://github.com/nvim-neotest/nvim-nio' },

    { src = 'https://github.com/mason-org/mason.nvim' },
    { src = 'https://github.com/jay-babu/mason-nvim-dap.nvim' },

    { src = 'https://github.com/mfussenegger/nvim-dap-python' },
  },
  setup = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('mason-nvim-dap').setup {
      automatic_installation = true,
      handlers = {},
      ensure_installed = { 'codelldb' },
    }

    dapui.setup {}

    vim.keymap.set('n', '<F1>', function() dap.step_into() end, { desc = 'Debug: Step Into' })

    vim.keymap.set('n', '<F2>', function() dap.step_over() end, { desc = 'Debug: Step Over' })

    vim.keymap.set('n', '<F3>', function() dap.step_out() end, { desc = 'Debug: Step Out' })

    vim.keymap.set('n', '<F5>', function() dap.continue() end, { desc = 'Debug: Start/Continue' })

    vim.keymap.set('n', '<F6>', function() dap.close() end, { desc = 'Debug: Stop' })

    vim.keymap.set('n', '<Leader>b', function() dap.toggle_breakpoint() end, { desc = 'Debug: Toggle Breakpoint' })

    vim.keymap.set(
      'n',
      '<Leader>B',
      function() dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ') end,
      { desc = 'Debug: Set Breakpoint' }
    )

    -- Change breakpoint icons
    vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
    vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
    local breakpoint_icons =
      { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
    for type, icon in pairs(breakpoint_icons) do
      local tp = 'Dap' .. type
      local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
      vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
    end

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    require('dap-python').setup 'uv'
  end,
}
