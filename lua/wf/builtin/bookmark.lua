local select = require("wf").select

local function bookmark(bookmark_dirs, opts)
  local function _bookmark()
    opts = opts or {}
    local _opts = {
      title = "Bookmark",
      behavior = {
        skip_front_duplication = true,
        skip_back_duplication = true,
      },
    }
    for k, v in pairs(opts) do
      _opts[k] = v
    end

    select(bookmark_dirs, _opts, function(path_, _)
      local path = vim.fn.expand(path_)
      if vim.fn.isdirectory(path) ~= 0 then
        if vim.fn.exists(":Telescope") then
          require("telescope").extensions.file_browser.file_browser({ path = path_, depth = 4 })
          return
        elseif vim.fn.exists(":CtrlP") then
          local command = "CtrlP " .. path
          vim.cmd(command)
          return
        elseif vim.g.loaded_netrwPlugin == 0 and vim.g.loaded_netrw == 0 then
          local command = "e " .. path
          vim.cmd(command)
          return
        else
          print("not matched")
        end
      elseif vim.fn.filereadable(path) ~= 0 then
        local command = "vi " .. path
        vim.cmd(command)
        return
      else
        print("The file/dir does not found")
      end
    end)
  end

  return _bookmark
end

return bookmark
