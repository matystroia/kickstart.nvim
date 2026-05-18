local Plug = require 'plugin.plug'
local firenvim = require 'plugin.firenvim'

---@param mod_path string
---@return Plug[]?
local function load_spec(mod_path)
  local mod = require(mod_path)
  if mod == true then
    return nil
  elseif vim.islist(mod) then
    return vim.iter(mod):map(Plug.from):totable()
  else
    return { Plug.from(mod) }
  end
end

---@return string[]
local function collect_mods()
  local plug_dirs = { 'basic', 'extra', 'lang', 'lsp', 'ui' }
  return vim
    .iter(plug_dirs)
    :map(function(mod)
      local mod_path = vim.fs.joinpath(vim.fn.stdpath 'config', 'lua/plugin', mod)
      return vim
        .iter(vim.fs.dir(mod_path))
        :map(function(name) return string.format('plugin.%s.%s', mod, name:gsub('%.lua$', '')) end)
        :totable()
    end)
    :flatten()
    :totable()
end

---@return Plug[]
local function collect_plugs()
  local mods ---@type string[]
  if vim.g.minimal or vim.g.started_by_firenvim then
    mods = {
      'plugin.basic.leap',
      'plugin.basic.mini-surround',
      'plugin.basic.nvim-autopairs',
      'plugin.basic.nvim-spider',
    }
  else
    mods = collect_mods()
  end

  local ret = vim.iter(mods):map(load_spec):flatten():totable()
  if vim.g.started_by_firenvim then table.insert(ret, Plug.from(firenvim)) end

  return ret
end

---@return table<string, Plug>
local function build_plugs()
  -- Top level plugins
  local plugs = collect_plugs()
  local ret = vim.iter(plugs):fold({}, function(acc, plug)
    if plug.enabled then acc[plug.name] = plug end
    return acc
  end)

  local function prioritize(plug)
    if plug.deps ~= nil then
      vim.iter(plug.deps):each(function(dep)
        if plug.priority + 1 > dep.priority then
          dep.priority = plug.priority + 1
          prioritize(dep)
        end
      end)
    end
  end
  vim.iter(ret):each(function(_, plug) prioritize(plug) end)

  -- Link existing to deps and add missing deps as top level
  vim.iter(ret):each(function(_, plug)
    if plug.deps ~= nil then
      for i, dep in ipairs(plug.deps) do
        if ret[dep.name] == nil then
          ret[dep.name] = dep
        else
          plug.deps[i] = ret[dep.name]
        end
      end
    end
  end)

  return ret
end

local plugs = build_plugs()

local sorted = vim.tbl_values(plugs)
table.sort(sorted, function(a, b) return a.priority > b.priority end)

vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    ---@cast ev {data: vim.event.packchanged.data}
    local name, kind = ev.data.spec.name, ev.data.kind
    local plug = ev.data.spec.data

    if not (kind == 'install' or kind == 'update') then return end

    if plug.build ~= nil then
      if not ev.data.active then
        if plug.deps ~= nil then vim.iter(plug.deps):each(function(dep) vim.cmd.packadd(dep.name) end) end
        vim.cmd.packadd(name)
      end
      plug.build(name, ev.data.path)
    end
  end,
})

local pack_spec = vim.iter(sorted):map(function(plug) return plug:pack_spec() end):totable()
vim.pack.add(pack_spec)

vim.iter(sorted):each(function(plug)
  if plug.setup ~= nil then
    if plug.deps ~= nil then vim.iter(plug.deps):each(function(dep) vim.cmd.packadd(dep.name) end) end
    plug.setup()
  end
end)
