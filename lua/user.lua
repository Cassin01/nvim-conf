local wf = require("wf")
wf.setup({theme="chad"})

local which_key = require("wf.builtin.which_key")
local register = require("wf.builtin.register")
local bookmark = require("wf.builtin.bookmark")

vim.api.nvim_set_keymap("n", "<Space>", "", {
  callback = which_key({ text_insert_in_advance = "<Space>" }),
  noremap = true,
  silent = true,
  desc = "which-key space",
  nowait = true,
})
vim.api.nvim_set_keymap("n", "<Space>wn", "", {
  callback = which_key(),
  noremap = true,
  silent = true,
  desc = "which-key",
  nowait = true,
})
vim.api.nvim_set_keymap("n", "s", "", {
  callback = which_key({ text_insert_in_advance = "s" }),
  noremap = true,
  silent = true,
  desc = "which-key s",
  nowait = true,
})
vim.api.nvim_set_keymap("n", "<Leader>", "", {
  callback = which_key({ text_insert_in_advance = "<Leader>" }),
  noremap = true,
  silent = true,
  desc = "which-key /",
  nowait = true,
})
vim.api.nvim_set_keymap("n", "<Space>wr", "", { callback = register(), noremap = true, silent = true, desc = "wf.nvim register" })
vim.api.nvim_set_keymap("n", "<Space>wb", "", { callback = bookmark({}), noremap = true, silent = true, desc = "wf.nvim bookmark" })
