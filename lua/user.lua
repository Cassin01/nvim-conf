local wf = require("wf")
-- wf.setup({ theme = "chad" })
-- wf.setup({theme="default"})

local which_key = require("wf.builtin.which_key")
local register = require("wf.builtin.register")
local bookmark = require("wf.builtin.bookmark")
local buffer = require("wf.builtin.buffer")
-- local mark = require("wf.builtin.mark")
-- local test = require("wf.builtin.test")
-- local sql = require("sql")

local bookmark_dirs = {
  ome = "~/.config/nvim",
  fnl = "~/.config/nvim/fnl",
  kaza = "~/.config/nvim/fnl/kaza",
  core = "~/.config/nvim/fnl/core",
  vim = "~/.config/nvim/vim",
  macros = "~/.config/nvim/lua/macros",
  packer = "~/.config/nvim/fnl/core/pack/plugs.fnl",
  snip = "~/.config/nvim/UltiSnips",
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

vim.api.nvim_set_keymap(
  "n",
  "<Space>wr",
  "",
  { callback = register(), noremap = true, silent = true, desc = "[wf.nvim] register" }
)
vim.api.nvim_set_keymap(
  "n",
  "<Space>wbo",
  "",
  { callback = bookmark(bookmark_dirs, {}), noremap = true, silent = true, desc = "[wf.nvim] bookmark" }
)
-- vim.api.nvim_set_keymap(
--  "n",
--  "<Space>wa",
--  "",
--  { callback = test, noremap = true, silent = true, desc = "[wf.nvim] test" }
-- )
vim.keymap.set(
    "n",
    "<Space>wbu",
    buffer({}),
    {noremap = true, silent= true, desc = "[wf.nvim] buffer"}
  )
-- vim.keymap.set(
--    "n",
--    "'",
--    mark({text_insert_in_advance="'"}),
--    {noremap = true, silent= true, desc = "[wf.nvim] mark"}
--  )

-- which_key
local key_group_dict = vim.fn.luaeval("_G.__kaza.prefix")
vim.api.nvim_set_keymap("n", "<Space>", "", {
  callback = which_key({ text_insert_in_advance = "<Space>", key_group_dict= key_group_dict }),
  noremap = true,
  silent = true,
  desc = "which-key space",
  nowait = true,
})
vim.api.nvim_set_keymap("n", "s", "", {
  callback = which_key({ text_insert_in_advance = "s", key_group_dict= key_group_dict  }),
  noremap = true,
  silent = true,
  desc = "which-key s",
  nowait = true,
})
vim.api.nvim_set_keymap("n", "<Leader>", "", {
  callback = which_key({ text_insert_in_advance = "<Leader>" , key_group_dict= key_group_dict }),
  noremap = true,
  silent = true,
  desc = "which-key /",
  nowait = true,
})
vim.api.nvim_create_autocmd({"BufEnter", "BufAdd"}, {
  group = vim.api.nvim_create_augroup("my_wf", { clear = true }),
  callback = function()
    vim.api.nvim_buf_set_keymap(0, "n", "<Space>", "", {
      callback = which_key({ text_insert_in_advance = "<Space>" , key_group_dict= key_group_dict }),
      noremap = true,
      silent = true,
      desc = "which-key space [buf]",
      nowait = true,
    })
    vim.api.nvim_buf_set_keymap(0, "n", "s", "", {
      callback = which_key({ text_insert_in_advance = "s" , key_group_dict= key_group_dict }),
      noremap = true,
      silent = true,
      desc = "which-key s [buf]",
      nowait = true,
    })
    vim.api.nvim_buf_set_keymap(0, "n", "<Leader>", "", {
      callback = which_key({ text_insert_in_advance = "<Leader>" , key_group_dict= key_group_dict }),
      noremap = true,
      silent = true,
      desc = "which-key / [buf]",
      nowait = true,
    })
  end,
})

local ns = vim.api.nvim_create_namespace("mhoge")
vim.api.nvim_set_keymap("n", "<Space>wf", "", {
    callback = function()
      local conf_ = {
        width = 100,
        relative = "editor",
        anchor = "NW",
        style = "minimal",
        border = "rounded",
        title = "Hoge",
        title_pos = "center",
      }
      local conf = vim.fn.extend(conf_, {
          height = 1,
          row = 10,
          col = 10,
        })
      local buf = vim.api.nvim_create_buf(false, true)
      local win = vim.api.nvim_open_win(buf, true, conf)
      vim.api.nvim_buf_set_option(buf, "buftype", "prompt")
      vim.fn.prompt_setprompt(buf, "Hoge> ")
      vim.api.nvim_buf_add_highlight(0,  ns, "TODO",0,0, 4)
      print(vim.inspect(vim.api.nvim_win_get_config(win)))

    end,
    noremap = true,
    silent = true,
    desc = "test",
    nowait = true,
  })

local input = require("wf.input").input
vim.keymap.set("n", "<Space>k", input, {noremap = true, desc = "test"})

local async = require("wf.util").async
vim.keymap.set("n", "<Space>K", function() 
  vim.schedule_wrap(function() vim.cmd("startinsert") end)()
  vim.schedule_wrap(function() vim.cmd("stopinsert") end)()
  vim.schedule_wrap(function() vim.cmd("startinsert") end)()
  end, {noremap = true, desc = "test"})
