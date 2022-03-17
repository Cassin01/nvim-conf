[{1 :preservim/nerdtree
  :setup (λ []
           (vim.cmd "nnoremap <space>r :NERDTreeCWD<CR>")
           (vim.cmd "nnoremap <space>s :NERDTreeToggle<CR>")
           (vim.cmd "nnoremap <space>n :NERDTreeFind<CR>"))}

 ;;; UI

 {1 :glepnir/dashboard-nvim
  :config (λ [] (tset vim.g :dashboard_default_executive :telescope))}
 {1 :rinx/nvim-minimap
  :config (λ []
            (vim.cmd "let g:minimap#window#width = 10")
            (vim.cmd "let g:minimap#window#height = 50"))}
 {1 :nvim-telescope/telescope.nvim
  :requires [:nvim-lua/plenary.nvim]
  :setup (λ []
           (vim.cmd "nnoremap <leader>tf <cmd>Telescope find_files<cr>")
           (vim.cmd "nnoremap <leader>tg <cmd>Telescope live_grep<cr>")
           (vim.cmd "nnoremap <leader>tb <cmd>Telescope buffers<cr>")
           (vim.cmd "nnoremap <leader>th <cmd>Telescope help_tags<cr>"))}
 {1 :xiyaowong/nvim-transparent}
 {1 :akinsho/bufferline.nvim
  :requires :kyazdani42/nvim-web-devicons}
 {1 :windwp/windline.nvim
  :config (λ []
            (require "wlsample.vscode")
            ((. (require "wlfloatline") :setup)
             {:always_active false
              :show_last_status false}))}
 {1 :nvim-treesitter/nvim-treesitter
  :run ":TSUpdate"
  :requires :p00f/nvim-ts-rainbow
  :config (λ []
            ((. (require "nvim-treesitter.configs") :setup)
             {:ensure_installed "maintained"
              :sync_install false
              :ignore_install [ "javascript" ]
              :highlight {:enable true
                          :disable [ "c" "rust" "lua"]
                          :additional_vim_regex_highlighting false}
              :rainbow {:enable true
                        :extended_mode true
                        :max_file_lines nil}}))}

 ;;; Colortheme

 :rafamadriz/neon

 ;;; Edit

 ;; lsp
 {1 :williamboman/nvim-lsp-installer
  :config (λ []
              ((. (require :nvim-lsp-installer) :on_server_ready)
                (λ [server] (server:setup {}))))}

 {1 :onsails/lspkind-nvim
  :config (λ [] ((. (require :lspkind) :init) {}))}

 ;; enhance quick fix
 {1 :kevinhwang91/nvim-bqf
  :ft :qf}

 {1 :weilbith/nvim-code-action-menu
  :cmd :CodeActionMenu}

 {1 :kosayoda/nvim-lightbulb
  :config (λ []
            ((. (require :nvim-lightbulb) :setup)
             {:ignore {}
              :sign {:enabled true
                     :priority 10 }
              :float {:enabled false
                      :text :💡
                      :win_opts {}}
              :virtual_text {:enabled false
                      :text :💡
                      :hl_mode :replace}
              :status_text {:enabled false
                      :text :💡
                      :text_unavilable ""}}))
  :setup (λ []
           (vim.cmd "autocmd CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()"))}

 ;; cmp plugins
 {1 :hrsh7th/nvim-cmp
  :requires [:hrsh7th/cmp-buffer       ; buffer completions
             :hrsh7th/cmp-path         ; path completions
             :hrsh7th/cmp-nvim-lsp
             :hrsh7th/cmp-nvim-lua
             :hrsh7th/cmp-cmdline      ; cmdline completions
             :hrsh7th/cmp-calc
             :quangnguyen30192/cmp-nvim-ultisnips
             :neovim/nvim-lspconfig
             ;:hrsh7th/vim-vsnip
             ;:saadparwaiz1/cmp_luasnip ; snippet completions
             ]
  :config (λ []
    (local cmp (require :cmp))
    (cmp.setup {:snippet {:expand (λ [args]
                                    (vim.fn.UltiSnips#Anon args.body))}
                :sources (cmp.config.sources [{:name :ultisnips} {:name :nvim_lsp}] [{:name :buffer}])})
    (cmp.setup.cmdline :/ {:sources [{:name :buffer}]})
    (cmp.setup.cmdline :: {:sources (cmp.config.sources [{:name :path}] [{:name :cmdline}])})
    )}

 {1 :neovim/nvim-lspconfig
  :config (λ []
    (local capabilities ((. (require :cmp_nvim_lsp) :update_capabilities) (vim.lsp.protocol.make_client_capabilities)))
    (each [_ key (ipairs [:rust_analyzer])]
    ((-> (require :lspconfig) (. key) (. :setup))
     {:capabilities capabilities})))}

 {1 :hrsh7th/vim-vsnip
  :requires [:hrsh7th/vim-vsnip-integ
             :rafamadriz/friendly-snippets]}

 ;; Show git status on left of a code.
 {1 :lewis6991/gitsigns.nvim
  :requires :nvim-lua/plenary.nvim
  :config (λ []
            ((. (require :gitsigns) :setup)
             {:current_line_blame true}))}

 ;;; vim

 {1 :Shougo/echodoc.vim
  :setup (λ []
            (tset vim.g :echodoc#enable_at_startup true)
            (tset vim.g :echodoc#type :floating))}

 ;;; language

 ;; lua
 :bfredl/nvim-luadev

 ;; fennel
 :bakpakin/fennel.vim  ; syntax
 :jaawerth/fennel-nvim ; native fennel support
 :Olical/conjure       ; interactive environment
 :Olical/nvim-local-fennel

 ;; markdown
 {1 :ellisonleao/glow.nvim
  :cmd [:Glow :GlowInstall]
  :run ":GlowInstall" }
 ]
