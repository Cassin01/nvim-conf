local wf = require("wf")
wf.setup()
local which_key = require("wf.builtin.which_key")

vim.api.nvim_set_keymap(
  "n",
  "<Space>",
  "",
  { callback = which_key("<Space>"), noremap = true, silent = true, desc = "which-key-space", nowait = true }
)
vim.api.nvim_set_keymap(
  "n",
  "s",
  "",
  { callback = which_key("s"), noremap = true, silent = true, desc = "which-key-s", nowait = true }
)
