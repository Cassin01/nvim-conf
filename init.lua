-- local root = vim.fn.fnamemodify("./.repro", ":p")
--
-- -- set stdpaths to use .repro
-- for _, name in ipairs({ "config", "data", "state", "cache" }) do
--   vim.env[("XDG_%s_HOME"):format(name:upper())] = root .. "/" .. name
-- end

-- bootstrap lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end

local hotpotpath = vim.fn.stdpath("data") .. "/lazy/hotpot.nvim"
if not vim.loop.fs_stat(hotpotpath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--single-branch",
    "--branch=master",
    "https://github.com/rktjmp/hotpot.nvim.git",
    hotpotpath,
  })
end

vim.opt.runtimepath:prepend({lazypath, hotpotpath})

require("hotpot")

if _G["__kaza"] == nil then
   require("kaza").setup()
end

require("core.opt")

-- install plugins
require("lazy").setup(require("plugs"))

-- my settings
require("setup")


-- vim.cmd([[colorscheme tokyonight]])
-- vim.cmd([[colorscheme lunaperche]])
-- vim.cmd([[colorscheme nord]])
-- vim.cmd([[colorscheme nova]])
vim.cmd([[colorscheme fluoromachine]]) -- default
-- vim.cmd([[colorscheme Tomorrow]])
-- vim.cmd([[colorscheme default]])

-- vim.cmd([[set background=light]])
-- vim.cmd([[colorscheme morning]])
