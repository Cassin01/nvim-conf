[{1 "preservim/nerdtree"
  :setup (lambda []
            (vim.cmd "nnoremap <space>r :NERDTreeCWD<CR>")
            (vim.cmd "nnoremap <space>s :NERDTreeToggle<CR>")
            (vim.cmd "nnoremap <space>n :NERDTreeFind<CR>"))}

 ;;;; UI

 {1 "glepnir/dashboard-nvim"
  :config (lambda [] (tset vim.g :dashboard_default_executive :telescope))}
 {1 "rinx/nvim-minimap"
  :config (lambda []
             (vim.cmd "let g:minimap#window#width = 10")
             (vim.cmd "let g:minimap#window#height = 50"))}
 {1 "nvim-telescope/telescope.nvim"
  :requires ["nvim-lua/plenary.nvim"]
  :setup (lambda []
            (vim.cmd "nnoremap <leader>tf <cmd>Telescope find_files<cr>")
            (vim.cmd "nnoremap <leader>tg <cmd>Telescope live_grep<cr>")
            (vim.cmd "nnoremap <leader>tb <cmd>Telescope buffers<cr>")
            (vim.cmd "nnoremap <leader>th <cmd>Telescope help_tags<cr>")) }
 {1 "xiyaowong/nvim-transparent"}
 {1 "akinsho/bufferline.nvim"
  :requires "kyazdani42/nvim-web-devicons" }
 {1 "windwp/windline.nvim"
  :config (lambda []
             (require "wlsample.vscode")
             ((. (require "wlfloatline") :setup)
              {:always_active false
               :show_last_status false}))}
 {1 "nvim-treesitter/nvim-treesitter"
  :run ":TSUpdate"
  :config (lambda []
    ((. (require "nvim-treesitter.configs") :setup)
     {:ensure_installed "maintained"
      :sync_install false
      :ignore_install [ "javascript" ]
      :highlight {
                  :enable true
                  :disable [ "c" "rust" "lua"]
                  :additional_vim_regex_highlighting false}}))}

 ;;;; language

 ;;; lua
 :bfredl/nvim-luadev

 ;;; fennel
 "bakpakin/fennel.vim"  ; syntax
 "jaawerth/fennel-nvim" ; native fennel support
 "Olical/conjure"       ; interactive environment
 "Olical/nvim-local-fennel"

 ;;; markdown
 {1 "ellisonleao/glow.nvim"
  :cmd [:Glow :GlowInstall]
  :run ":GlowInstall" }
 ]
