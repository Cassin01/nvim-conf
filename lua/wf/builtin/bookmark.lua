local select = require("wf").select

local function bookmark(opts)
  local function _bookmark()
    local bookmark_dir = {
      ome = "~/.config/nvim",
      fnl = "~/.config/nvim/fnl",
      kaza = "~/.config/nvim/fnl/kaza",
      core = "~/.config/nvim/fnl/core",
      vim = "~/.config/nvim/vim",
      macros = "~/.config/nvim/lua/macros",
      packer = "~/.config/nvim/fnl/core/pack/plugs.fnl",
      snip = "~/.config/nvim/UltiSnips",
      witch = "~/.config/nvim/plugin/hyper_witch.vim",
      dotfile = "~/dotfiles",
      memo = "~/tech-memo",
      ["nvimfnl"] = "~/.cache/nvim/hotpot/Users/cassin/.config/nvim/fnl",
      ["nvim<Space>lua"] = "~/.cache/nvim/hotpot/Users/cassin/.config/nvim/lua",
      org = "~/org/",
      projects = "~/all_year",
      lab = "~/2022/lab",
      sche = "~/.config/nvim/data/10.sche",
      ghq = "~/ghq",
    }

    opts = opts or {}
    local _opts = {
      title = "Bookmark",
      behavior = {
        skip_head_duplication = true,
        shortest_match = true,
      },
    }
    for k, v in pairs(opts) do
      _opts[k] = v
    end

    select(bookmark_dir, _opts, function(paths, lhs)
      local path = vim.fn.expand(paths[lhs])
      if vim.fn.isdirectory(path) then
        if vim.fn.exists(":Telescope") then
          require("telescope").extensions.file_browser.file_browser({ path = paths, depth = 4 })
          return
        elseif vim.fn.exists(":CtrlP") then
          local command = "CtrlP " .. path
          vim.cmd(command)
          return
        elseif vim.g.loaded_netrwPlugin ~= 1 then
          local command = "e " .. path
          vim.cmd(command)
          return
        else
          print("not matched")
        end
      else
        local command = "vi " .. path
        vim.cmd(command)
        return
      end
    end)
  end

  return _bookmark
end

return bookmark
