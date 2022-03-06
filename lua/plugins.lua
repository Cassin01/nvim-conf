local local_package_path = "./?.lua;/Users/cassin/.config/nvim/lua5.1/share/lua/5.1/?.lua;/Users/cassin/.config/nvim/lua5.1/share/lua/5.1/?/init.lua"
package.path = package.path..';'..local_package_path

vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function()
  -- Packer can manage itself
  use {'wbthomason/packer.nvim',
      setup=function()
      end
  }

  -------------------------------------------------------------
  -- Lua librarys
  -------------------------------------------------------------

  use_rocks 'fennel'
  use_rocks 'luacheck'
  use_rocks 'luasocket'
  use_rocks 'effil'

  -------------------------------------------------------------
  -- Another Plugins
  -------------------------------------------------------------


  use { 'ms-jpq/lua-async-await' }

  -- hotload
  -- use {'notomo/lreload.nvim', opt=true}

  -- reload configuration
  -- use {'famiu/nvim-reload'}


  -- use {'kyazdani42/nvim-tree.lua',
  --     requires = {
  --         'kyazdani42/nvim-web-devicons', -- optional, for file icon
  --     },
  --     setup = function()
  --         vim.api.nvim_set_keymap('n', '<Space>s', [[<Cmd>NvimTreeToggle<CR>]], {noremap=true, silent=true})
  --         vim.api.nvim_set_keymap('n', '<Space>r', [[<Cmd>NvimTreeReresh<CR>]], {noremap=true})
  --         vim.api.nvim_set_keymap('n', '<Space>n', [[<Cmd>NvimTreeFindFile<CR>]], {noremap=true})
  --     end,
  --     config = function()
  --         require'nvim-tree'.setup {}
  --     end
  -- }

  use {'preservim/nerdtree',
      setup=function()
          vim.cmd([[nnoremap <space>r :NERDTreeCWD<CR>]])
          vim.cmd([[nnoremap <space>s :NERDTreeToggle<CR>]])
          vim.cmd([[nnoremap <space>n :NERDTreeFind<CR>]])
      end
  }

  -------------------------------------------------------------
  -- UI
  -------------------------------------------------------------
  -- {{{
  -- starting page
   use { 'glepnir/dashboard-nvim',
       config=function()
           vim.cmd([[let g:dashboard_default_executive ='telescope']])
           vim.cmd([[
 let g:dashboard_custom_shortcut={
 \ 'last_session'       : 'SPC l s l',
 \ 'find_history'       : 'SPC l f h',
 \ 'find_file'          : 'SPC l f f',
 \ 'new_file'           : 'SPC l c n',
 \ 'change_colorscheme' : 'SPC l t c',
 \ 'find_word'          : 'SPC l f a',
 \ 'book_marks'         : 'SPC l f b',
 \ }]])
       end
   }

  -- minimap
  use {'rinx/nvim-minimap',
      config=function()
          vim.cmd([[let g:minimap#window#width = 10]])
          vim.cmd([[let g:minimap#window#height = 50]])
      end
  }

  use {'wfxr/minimap.vim',
      config=function()
        _G.minimap_auto_start=1
        _G.minimap_auto_start_win_enter = 1
      end
  }

  use {'nvim-telescope/telescope.nvim',
      requires = { {'nvim-lua/plenary.nvim'} },
      setup=function()
          vim.cmd([[nnoremap <leader>tf <cmd>Telescope find_files<cr>]])
          vim.cmd([[nnoremap <leader>tg <cmd>Telescope live_grep<cr>]])
          vim.cmd([[nnoremap <leader>tb <cmd>Telescope buffers<cr>]])
          vim.cmd([[nnoremap <leader>th <cmd>Telescope help_tags<cr>]])
      end
  }

  use { 'xiyaowong/nvim-transparent'}

  -- one window
 use { 'windwp/windline.nvim',
     config=function()
         -- require'wlsample.evil_line'
         --require('wlsample.wind')
         -- require('wlsample.basic')
         require('wlsample.vscode')
         require('wlfloatline').setup({
                 always_active = false,
                 show_last_status = false,
             })
     end
 }


  -- which key
  -- use {
  --     "folke/which-key.nvim",opt=true,
  --     setup = function()
  --         require("which-key").setup {}
  --         --local presets = require("which-key.plugins.presets")
  --         --presets.operators["i"] = nil
  --         --presets.operators["v"] = nil
  --     end
  -- }

use { 'delphinus/skkeleton_indicator.nvim',
    config = function()
        vim.api.nvim_exec([[
          hi SkkeletonIndicatorEiji guifg=#88c0d0 guibg=#2e3440 gui=bold
          hi SkkeletonIndicatorHira guifg=#2e3440 guibg=#a3be8c gui=bold
          hi SkkeletonIndicatorKata guifg=#2e3440 guibg=#ebcb8b gui=bold
          hi SkkeletonIndicatorHankata guifg=#2e3440 guibg=#b48ead gui=bold
          hi SkkeletonIndicatorZenkaku guifg=#2e3440 guibg=#88c0d0 gui=bold
        ]], false)
        require'skkeleton_indicator'.setup {}
    end
}

 
use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate',
    config = function()
        require'nvim-treesitter.configs'.setup {
              ensure_installed = "maintained",
              sync_install = false,
              ignore_install = { "javascript" },
              highlight = {
                  enable = true,
                  disable = { "c", "rust" , "lua"},
                  additional_vim_regex_highlighting = false,
              },
        }
    end
}

  -- rainbow bracket
  -- }}}

  -------------------------------------------------------------
  -- language
  -------------------------------------------------------------

  -- fennel {{{
  use 'bakpakin/fennel.vim'  -- syntax
  use 'jaawerth/fennel-nvim' -- native fennel support
  use {
      'Olical/conjure',
      setup = function()
         --  vim.cmd([[let g:conjure#filetype#fennel = "conjure.client.fennel.stdio"]])
      end
  }       -- interactive environment
  use 'Olical/nvim-local-fennel'
  -- use {'Olical/aniseed'}
  -- use {'rktjmp/hotpot.nvim',
  --   -- packer says this is "code to run after this plugin is loaded."
  --   -- but it seems to run before plugin/hotpot.vim (perhaps just barely)
  --   setup = function()
  --       -- _G.conjure.filetype.fennel = "conjure.client.fennel.stdio"
  --       -- Evaluate and Print Selection
  --       vim.api.nvim_set_keymap("v",
  --                       "<leader>fe",
  --                       "<cmd>lua print(require('hotpot.api.eval')['eval-selection']())<cr>",
  --                       {noremap = true, silent = false})

  --       -- Compile and Primt buffer
  --       vim.api.nvim_set_keymap("n",
  --           "<leader>fc",
  --           "<cmd>lua print(require('hotpot.api.compile')['compile-buffer'](0))<cr>",
  --           {noremap = true, silent = false})

  --       -- Open Cached Lua file {{{
  --       function _G.open_cache()
  --           local cache_path_fn = require("hotpot.api.cache")["cache-path-for-fnl-file"]
  --           local fnl_file = vim.fn.expand("%:p")
  --           local lua_file = cache_path_fn(fnl_file)
  --           if lua_file then
  --               vim.cmd(":new " .. lua_file)
  --           else
  --               print("No matching cache file for current file")
  --           end
  --       end

  --       vim.api.nvim_set_keymap("n",
  --           "<leader>ff",
  --           "<cmd>lua open_cache()<cr>",
  --           {noremap = true, silent = false})
  --       -- }}}
  --   end,
  --   config = function() require("hotpot") end
  -- }

  --use 'tsbohc/zest.nvim' -- vim-specific macro
  -- }}}

  use {"ellisonleao/glow.nvim",
      cmd={'Glow', 'GlowInstall'},
      run=[[:GlowInstall]]
  }

  -- use {'edluffy/hologram.nvim',
  --     config = function()
  --         require'hologram'.setup {}
  --         -- local function map(input, output)
  --         --     vim.api.nvim_set_keymap('n', input, output, { noremap = true, silent = false})
  --         -- end
  --         -- local my_image
  --         -- function Start()
  --         --     my_image = require('hologram.image'):new({ source="/Users/cassin/Downloads/ex1.png", row=2,col=40})
  --         --     my_image:transmit()
  --         -- end
  --         -- function End()
  --         --   print(my_image:delete())
  --         -- end
  --         -- map('<space>lls', ":lua Start()<cr>")
  --         -- map('<space>lle', ":lua End()<cr>")
  --     end,
  -- }


end)
