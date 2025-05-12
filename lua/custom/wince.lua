local M = {}

local function intersects(a, b, x, y)
  return (a >= x and a <= y) or (b >= x and b <= y)
end

local function edge_intersects(e1, e2, axis)
  local a, b
  if axis == 'v' then
    a, b = 'up', 'down'
  elseif axis == 'h' then
    a, b = 'left', 'right'
  end
  return intersects(e1[a], e1[b], e2[a], e2[b])
end

local function get_edges(window_id)
  local pos = vim.api.nvim_win_get_position(window_id)
  local cfg = vim.api.nvim_win_get_config(window_id)
  return {
    left = pos[2],
    right = pos[2] + cfg.width,
    up = pos[1],
    down = pos[1] + cfg.height,
  }
end

local function get_neighbors(window_id)
  local edges = get_edges(window_id)

  local windows = vim
    .iter(vim.api.nvim_tabpage_list_wins(0))
    :filter(function(win_id)
      return win_id ~= window_id
    end)
    :map(function(win_id)
      return { nr = vim.api.nvim_win_get_number(win_id), edges = get_edges(win_id) }
    end)

  local ret = { left = nil, right = nil, up = nil, down = nil }
  windows:each(function(win)
    if win.edges.right + 1 == edges.left and edge_intersects(win.edges, edges, 'v') then
      ret.left = win.nr
    elseif win.edges.left - 1 == edges.right and edge_intersects(win.edges, edges, 'v') then
      ret.right = win.nr
    elseif win.edges.down + 1 == edges.up and edge_intersects(win.edges, edges, 'h') then
      ret.up = win.nr
    elseif win.edges.up - 1 == edges.down and edge_intersects(win.edges, edges, 'h') then
      ret.down = win.nr
    end
  end)

  return ret
end

function M.resize(dir, count)
  local win_id = vim.api.nvim_get_current_win()
  local neighbors = get_neighbors(win_id)

  local vertical
  if dir == 'left' or dir == 'right' then
    vertical = 'vertical '
  else
    vertical = ''
  end

  if dir == 'right' and not neighbors.left then
    return vim.cmd('vertical resize +' .. count)
  elseif dir == 'down' and not neighbors.up then
    return vim.cmd('resize +' .. count)
  end

  local winnr = neighbors[dir] or ''

  local cmd = vertical .. winnr .. 'resize -' .. count

  vim.cmd(cmd)
end

return M
