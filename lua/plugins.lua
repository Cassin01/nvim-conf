local local_package_path = "./?.lua;/Users/cassin/.config/nvim/lua5.1/share/lua/5.1/?.lua;/Users/cassin/.config/nvim/lua5.1/share/lua/5.1/?/init.lua"
package.path = package.path..';'..local_package_path

vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function()
  -- Packer can manage itself
  use {'wbthomason/packer.nvim', opt=true}

  use {
      'kyazdani42/nvim-tree.lua',
      requires = {
          'kyazdani42/nvim-web-devicons', -- optional, for file icon
      },
      setup = function()
          vim.api.nvim_set_keymap('n', '<Space>s', [[<Cmd>NvimTreeToggle<CR>]], {noremap=true, silent=true})
          vim.api.nvim_set_keymap('n', '<Space>r', [[<Cmd>NvimTreeReresh<CR>]], {noremap=true})
          vim.api.nvim_set_keymap('n', '<Space>n', [[<Cmd>NvimTreeFindFile<CR>]], {noremap=true})
      end,
      config = function()
          require'nvim-tree'.setup {}
      end
  }

  -- which key
  use {
  "folke/which-key.nvim",
  config = function()
    require("which-key").setup {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    }
  end
}

  -- rainbow bracket
  use {'p00f/nvim-ts-rainbow'}

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
  use {'Olical/aniseed'}
  use {
    'rktjmp/hotpot.nvim',
    -- packer says this is "code to run after this plugin is loaded."
    -- but it seems to run before plugin/hotpot.vim (perhaps just barely)
    setup = function()
        -- _G.conjure.filetype.fennel = "conjure.client.fennel.stdio"
        -- Evaluate and Print Selection
        vim.api.nvim_set_keymap("v",
                        "<leader>fe",
                        "<cmd>lua print(require('hotpot.api.eval')['eval-selection']())<cr>",
                        {noremap = true, silent = false})

        -- Compile and Primt buffer
        vim.api.nvim_set_keymap("n",
            "<leader>fc",
            "<cmd>lua print(require('hotpot.api.compile')['compile-buffer'](0))<cr>",
            {noremap = true, silent = false})

        -- Open Cached Lua file {{{
        function _G.open_cache()
            local cache_path_fn = require("hotpot.api.cache")["cache-path-for-fnl-file"]
            local fnl_file = vim.fn.expand("%:p")
            local lua_file = cache_path_fn(fnl_file)
            if lua_file then
                vim.cmd(":new " .. lua_file)
            else
                print("No matching cache file for current file")
            end
        end

        vim.api.nvim_set_keymap("n",
            "<leader>ff",
            "<cmd>lua open_cache()<cr>",
            {noremap = true, silent = false})
        -- }}}
    end,
    config = function() require("hotpot") end
  }

  use 'tsbohc/zest.nvim' -- vim-specific macro
  -- }}}

  use_rocks {'fennel', 'luacheck'}
end)
