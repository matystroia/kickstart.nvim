local M = {}

local session_dir = vim.fs.joinpath(vim.fn.stdpath 'data', 'session')
if not vim.uv.fs_stat(session_dir) then vim.uv.fs_mkdir(session_dir, tonumber('755', 8)) end

function M.load_session()
  local sessions = vim.fs.find(
    function(name) return vim.endswith(name, '.vim') end,
    { path = session_dir, type = 'file' }
  )
  vim.ui.select(
    sessions,
    { kind = 'file', prompt = 'Session', format_item = function(item) return item:match '.+/(.+)%.vim$' end },
    function(session)
      if session ~= nil then vim.cmd.source(session) end
    end
  )
end

function M.create_session()
  vim.ui.input({ prompt = 'Session name: ', scope = 'editor' }, function(name)
    if name == nil then return end
    if not name:match '[%l-]+' then
      vim.print 'Invalid name'
      return
    end
    local file = vim.fs.joinpath(session_dir, name .. '.vim')
    vim.cmd.mksession(file)
    vim.print('Created session at ' .. file)
  end)
end

function M.save_session()
  if vim.v.this_session == '' then
    vim.print 'Not in a session'
  else
    vim.cmd.mksession { args = { vim.v.this_session }, bang = true }
    vim.print('Saved session at ' .. vim.v.this_session)
  end
end

return M
