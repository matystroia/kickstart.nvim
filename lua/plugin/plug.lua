---@class Plug
---@field src string
---@field name string
---@field version vim.VersionRange?
---@field deps Plug[]
---@field enabled boolean
---@field priority number
---@field setup function?
---@field build function?
local M = {}
M.__index = M

---@class PlugSpec
---@field src string
---@field version vim.VersionRange?
---@field deps PlugSpec[]?
---@field enabled boolean?
---@field priority number?
---@field setup function?
---@field build function?

---@param spec PlugSpec
---@return Plug
function M.from(spec)
  local self = setmetatable({}, M)

  self.src = spec.src
  self.name = spec.src:match '/[^/]+/([^/]+)$'
  self.version = spec.version

  if spec.deps ~= nil then
    self.deps = vim.iter(spec.deps):map(M.from):totable()
  end

  if spec.enabled ~= nil then
    self.enabled = spec.enabled
  else
    self.enabled = true
  end

  if spec.priority ~= nil then
    self.priority = spec.priority
  else
    self.priority = 0
  end

  self.setup = spec.setup
  self.build = spec.build

  return self
end

---@return vim.pack.Spec
function M:pack_spec()
  return { src = self.src, version = self.version, data = self }
end

return M
