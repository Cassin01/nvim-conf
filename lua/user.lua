local wf = require("wf")
wf.setup({ theme = "chad" })
-- wf.setup({theme="default"})

local which_key = require("wf.builtin.which_key")
local register = require("wf.builtin.register")
local bookmark = require("wf.builtin.bookmark")
local test = require("wf.builtin.test")

vim.api.nvim_set_keymap(
  "n",
  "<Space>wr",
  "",
  { callback = register(), noremap = true, silent = true, desc = "wf.nvim register" }
)
vim.api.nvim_set_keymap(
  "n",
  "<Space>wb",
  "",
  { callback = bookmark({}), noremap = true, silent = true, desc = "wf.nvim bookmark" }
)
vim.api.nvim_set_keymap(
  "n",
  "<Space>wa",
  "",
  { callback = test, noremap = true, silent = true, desc = "[wf.nvim] test" }
)

vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("my_wf", { clear = true }),
  callback = function()
    vim.api.nvim_buf_set_keymap(0, "n", "<Space>", "", {
      callback = which_key({ text_insert_in_advance = "<Space>" }),
      noremap = true,
      silent = true,
      desc = "which-key space",
      nowait = true,
    })
    vim.api.nvim_buf_set_keymap(0, "n", "s", "", {
      callback = which_key({ text_insert_in_advance = "s" }),
      noremap = true,
      silent = true,
      desc = "which-key s",
      nowait = true,
    })
    vim.api.nvim_buf_set_keymap(0, "n", "<Leader>", "", {
      callback = which_key({ text_insert_in_advance = "<Leader>" }),
      noremap = true,
      silent = true,
      desc = "which-key /",
      nowait = true,
    })
  end,
})
