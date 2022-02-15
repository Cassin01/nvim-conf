--
-- ██╗███╗   ██╗██╗████████╗██╗   ██╗██╗███╗   ███╗
-- ██║████╗  ██║██║╚══██╔══╝██║   ██║██║████╗ ████║
-- ██║██╔██╗ ██║██║   ██║   ██║   ██║██║██╔████╔██║
-- ██║██║╚██╗██║██║   ██║   ╚██╗ ██╔╝██║██║╚██╔╝██║
-- ██║██║ ╚████║██║   ██║██╗ ╚████╔╝ ██║██║ ╚═╝ ██║
-- ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝╚═╝  ╚═══╝  ╚═╝╚═╝     ╚═╝
--
--                 presented by
--
--               ╔═╗┌─┐┌─┐┌─┐┬┌┐┌
--               ║  ├─┤└─┐└─┐││││
--               ╚═╝┴ ┴└─┘└─┘┴┘└┘
--
--
local local_package_path = "./?.lua;/Users/cassin/.config/nvim/lua5.1/share/lua/5.1/?.lua;/Users/cassin/.config/nvim/lua5.1/share/lua/5.1/?/init.lua"
package.path = package.path..';'..local_package_path

local fennel = require('fennel')

require('conf')
vim.cmd[[autocmd BufWritePost plugins.lua PackerCompile]]


require('plugins')

-- vim.cmd("runtime init/main/main.init.vim")
vim.cmd("runtime init/main/nnormap.init.vim")
vim.cmd("runtime init/main/othermap.init.vim")
vim.cmd("runtime init/plugin/plugin_install.init.vim")
vim.cmd("runtime init/plugin/plugin_settings.init.vim")
vim.cmd("runtime init/color/color.init.vim")


function Script_path()
   local str = debug.getinfo(2, "S").source:sub(2)
   return str:match("(.*/)")
end
print(Script_path())
