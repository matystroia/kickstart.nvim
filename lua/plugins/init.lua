local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

local plugin_modules = {
  'plugins.basic',
  'plugins.extra',
  'plugins.lang',
}

local firenvim = require 'plugins.firenvim'
if vim.g.started_by_firenvim then
  firenvim.setup()
end

local spec = vim
  .iter(plugin_modules)
  :map(function(module)
    return { import = module }
  end)
  :totable()

require('lazy').setup {
  spec = {
    spec,
    firenvim.spec,
  },
  defaults = {
    cond = firenvim.plugin_cond,
  },
  change_detection = {
    notify = false,
  },
}
