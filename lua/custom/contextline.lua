local M = {}

local state = {
  context = nil,
}

local function has_parser(buf)
  return vim.bo[buf].filetype ~= '' and vim.treesitter.get_parser(buf, nil, { error = false }) ~= nil
end

---@type fun(buf: integer): TSNode[]
local function get_node_path(buf)
  local node = vim.treesitter.get_node { bufnr = buf }
  if node == nil then
    return {}
  end

  ---@type TSNode[]
  local ret = {}

  ---@type TSNode?
  local n = node:tree():root()
  while n do
    ret[#ret + 1] = n
    n = n:child_with_descendant(node)
  end

  return ret
end

---@type fun(buf: integer)
local function tick(buf)
  if buf ~= vim.api.nvim_win_get_buf(0) then
    return
  end

  ---@type {types: string[]; render: fun(n: TSNode): string|nil; hl_group: string}[]
  local node_types = {
    {
      types = { 'class_definition' },
      render = function(n)
        return vim.treesitter.get_node_text(n:field('name')[1], buf)
      end,
      hl_group = 'Type',
    },
    {
      types = { 'impl_item' },
      render = function(n)
        return vim.treesitter.get_node_text(n:field('type')[1], buf)
      end,
      hl_group = 'Type',
    },
    {
      types = { 'function_declaration', 'function_definition', 'arrow_function', 'function_item' },
      render = function(n)
        local name = n:field('name')[1]
        return name ~= nil and (vim.treesitter.get_node_text(name, buf) .. '()') or '()'
      end,
      hl_group = 'Function',
    },
    {
      -- Maps
      types = { 'field' },
      render = function(n)
        local name = n:field('name')[1]
        return name ~= nil and vim.treesitter.get_node_text(name, buf) or nil
      end,
      hl_group = '@property',
    },
    {
      -- QML
      types = { 'ui_object_definition' },
      render = function(n)
        return vim.treesitter.get_node_text(n:field('type_name')[1], buf)
      end,
      hl_group = 'Type',
    },
  }

  local ret = vim
    .iter(get_node_path(buf))
    :map(function(n)
      local type = n:type()
      local node_type = vim.iter(node_types):find(function(t)
        return vim.list_contains(t.types, type)
      end)

      if node_type == nil then
        return nil
      end

      local render = node_type.render(n)
      if render == nil then
        return nil
      end

      return '%#' .. node_type.hl_group .. '#' .. render .. '%*'
    end)
    :filter(function(n)
      return n ~= nil
    end)
    :join '  '

  state.context = ret
end

M.setup = function()
  local timer, err = vim.uv.new_timer()
  if timer == nil then
    vim.notify_once('ContextLine: ' .. err, vim.log.levels.ERROR)
    return
  end

  local group = vim.api.nvim_create_augroup('context-line', { clear = true })

  vim.api.nvim_create_autocmd('BufEnter', {
    group = group,
    callback = function()
      local buf = vim.api.nvim_get_current_buf()

      if vim.b._contextline_active == nil then
        vim.b._contextline_active = has_parser(buf)
      end

      if vim.b._contextline_active == false then
        return
      end

      local wrapped_tick = vim.schedule_wrap(tick)
      timer:start(0, 500, function()
        wrapped_tick(buf)
      end)
    end,
  })

  vim.api.nvim_create_autocmd('BufLeave', {
    group = group,
    callback = function()
      timer:stop()
    end,
  })

  vim.api.nvim_create_autocmd('VimLeavePre', {
    group = group,
    callback = function()
      timer:close()
    end,
  })
end

M.context = function()
  return vim.b._contextline_active and state.context or ''
end

return M
