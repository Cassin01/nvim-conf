[
 ;;; UI

 {1 :preservim/nerdtree
  :setup (λ []
           (local nerdtree ((. (require :kaza.map) :prefix-o) :<space>n :nerdtree))
           (nerdtree.map :n :c :<cmd>NERDTreeCWD<CR> "cwd")
           (nerdtree.map :n :t :<cmd>NERDTreeToggle<CR> "toggle")
           (nerdtree.map :n :f :<cmd>NERDTreeFind<CR> "find"))}
 {1 :glepnir/dashboard-nvim
  :config (λ [] (tset vim.g :dashboard_default_executive :telescope))}
 {1 :rinx/nvim-minimap
  :config (λ []
            (vim.cmd "let g:minimap#window#width = 10")
            (vim.cmd "let g:minimap#window#height = 50"))}
 {1 :nvim-telescope/telescope.nvim
  :requires [:nvim-lua/plenary.nvim ]
  :setup (λ []
           (local prefix ((. (require :kaza.map) :prefix-o) :<space>t :telescope))
           (prefix.map :n :f "<cmd>Telescope find_files<cr>" "find files")
           (prefix.map :n :g "<cmd>Telescope live_grep<cr>" "live grep")
           (prefix.map :n :b "<cmd>Telescope buffers<cr>" "buffers")
           (prefix.map :n :h "<cmd>Telescope help_tags<cr>" "help tags")
           (prefix.map :n :t "<cmd>Telescope<cr>" "telescope"))}
 {1 :xiyaowong/nvim-transparent
  :disable true
  :config (λ []
            ((-> (require :transparent) (. :setup))
             {:enable false}))}
 {1 :akinsho/bufferline.nvim
  :requires :kyazdani42/nvim-web-devicons}
 {1 :windwp/windline.nvim
  :disable true
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
 {1 :norcalli/nvim-colorizer.lua
  :config (λ []
            ((. (require :colorizer) :setup)))}

 {1 :ctrlpvim/ctrlp.vim
  :setup (λ []
           (local g vim.g)
           (tset g :ctrlp_map :<Nop>)
           (tset g :ctrlp_working_path_mode :ra)
           (tset g :ctrlp_open_new_file :r)
           (tset g :ctrlp_extensions [:tag :quickfix :dir :line :mixed])
           (tset g :ctrlp_match_window "bottom,order:btt,min:1,max:18")
           (local ctrlp ((. (require :kaza.map) :prefix-o) :<space>p :ctrlp))
           (ctrlp.map :n :a :<cmd>CtrlP<Space> :folder)
           (ctrlp.map :n :b :<cmd>CtrlPBuffer<cr> :buffer)
           (ctrlp.map :n :d :<cmd>CtrlPDir<cr> "directory")
           (ctrlp.map :n :f :<cmd>CtrlP<cr> "all files")
           (ctrlp.map :n :l :<cmd>CtrlPLine<cr> "grep in a current file")
           (ctrlp.map :n :m :<cmd>CtrlPMRUFiles<cr> "file history")
           (ctrlp.map :n :q :<cmd>CtrlPQuickfix<cr> "quickfix")
           (ctrlp.map :n :s :<cmd>CtrlPMixed<cr> "file and buffer")
           (ctrlp.map :n :t :<cmd>CtrlPTag<cr> "tag"))}



 ;; Show git status on left of a code.
 {1 :lewis6991/gitsigns.nvim
  :requires :nvim-lua/plenary.nvim
  :config (λ []
            ((. (require :gitsigns) :setup)
             {:current_line_blame true}))}

 {1 :majutsushi/tagbar
  :setup (λ []
           (tset vim.g :tagbar_type_fennel {:ctagstype :fennel
                                            :sort 0
                                            :kinds ["f:functions" "v:variables"]})
           ((. ((. (require :kaza.map) :prefix-o) :<space>a :tagbar) :map)
            :n :t :<cmd>TagbarToggle<cr> :toggle))}

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

 {1 :tami5/lspsaga.nvim
  :config ((. (require :lspsaga) :setup)
           {:code_action_prompt {:virtual_text false}})}

 {1 :kosayoda/nvim-lightbulb
  :disable true
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

 ;; error list
 {1 :folke/trouble.nvim
  :requires :yazdani42/nvim-web-devicons
  :config (λ [] ((-> (require :trouble) (. :setup)) {}))}

;; show type of argument
{1 :ray-x/lsp_signature.nvim
 :config ((. (require :lsp_signature) :setup) {})}

;; cmp plugins
{1 :hrsh7th/nvim-cmp
 :requires [:hrsh7th/cmp-buffer       ; buffer completions
            :hrsh7th/cmp-path         ; path completions
            :hrsh7th/cmp-nvim-lsp
            :hrsh7th/cmp-nvim-lua
            :hrsh7th/cmp-cmdline      ; cmdline completions
            :hrsh7th/cmp-calc
            :quangnguyen30192/cmp-nvim-ultisnips
            :neovim/nvim-lspconfig]
 :config (λ []
           (local cmp (require :cmp))
           (cmp.setup {:snippet {:expand (λ [args]
                                           (vim.fn.UltiSnips#Anon args.body))}
                       :sources (cmp.config.sources [{:name :ultisnips} {:name :nvim_lsp}]
                                                    [{:name :buffer
                                                      :option {:get_bufnrs (λ []
                                                                             (vim.api.nvim_list_bufs))}}])})
           (cmp.setup.cmdline :/ {:sources [{:name :buffer}]})
           (cmp.setup.cmdline :: {:sources (cmp.config.sources [{:name :path}] [{:name :cmdline}])}))}

{1 :neovim/nvim-lspconfig
 :config (λ []
           (local capabilities ((. (require :cmp_nvim_lsp) :update_capabilities) (vim.lsp.protocol.make_client_capabilities)))
           (each [_ key (ipairs [:rust_analyzer])]
             ((-> (require :lspconfig) (. key) (. :setup))
              {:capabilities capabilities})))}

{1 :hrsh7th/vim-vsnip
 :requires [:hrsh7th/vim-vsnip-integ
            :rafamadriz/friendly-snippets]}

{1 :folke/which-key.nvim
 :disable true
 :config (λ []
           ((-> (require :which-key) (. :setup)) {})
           (local presets (require :which-key.plugins.presets))
           (tset presets.operators :i nil)
           (tset presets.operators :v nil))}

;;; vim

{1 :Shougo/echodoc.vim
 :setup (λ []
          (tset vim.g :echodoc#enable_at_startup true)
          (tset vim.g :echodoc#type :floating))}

;; thank you tpope
:tpope/vim-fugitive
:tpope/vim-rhubarb ; enable :Gbrowse
:tpope/vim-commentary
:tpope/vim-unimpaired
:tpope/vim-surround
:tpope/vim-repeat
:github/copilot.vim
:tpope/vim-sexp-mappings-for-regular-people
{1 :guns/vim-sexp
 :setup (λ []
          (tset vim.g :sexp_filetypes "clojure,scheme,lisp,timl,fennel")
          (tset vim.g :sexp_enable_insert_mode_mappings false))}

;; util

{1 :tyru/open-browser.vim
 :config (λ []
           (local prefix ((. (require :kaza.map) :prefix-o) :<leader>s :open-browser))
           (prefix.map :n "" "<Plug>(openbrowser-smart-search)" "search")
           (prefix.map :v "" "<Plug>(openbrowser-smart-search)" "search"))}

{1 :mbbill/undotree
 :setup (λ []
           ((. ((. (require :kaza.map) :prefix-o) :<space>u :undo-tree) :map)
            :n :t :<cmd>UndotreeToggle<cr> :toggle))}

;;; game

:mattn/mahjong-vim

;;; language

;; org
:jceb/vim-orgmode
{1 :dhruvasagar/vim-dotoo
 :disable true
 :setup (λ []
          (tset vim.g :org_agenda_files
                ["~/org/*.org"
                 "~/Library/Mobile Documents/iCloud~com~appsonthemove~beorg/Documents/org/*.org"]))}

{1 :nvim-neorg/neorg
 :ft :norg
 :after :nvim-treesitter
 :config (λ []
           ((. (require :neorg) :setup)
            {:load {:core.defaults {}
                    :core.keybinds {:config {:default_keybinds true
                                             :neorg_leader :<Leader>n}}
                    :core.norg.completion {:config {:engine :nvim-cmp}}
                    :core.norg.concealer {:config {:icons {:todo {:enabled true
                                                                  :done {:enabled true
                                                                         :icon ""}
                                                                  :pending {:enabled true
                                                                            :icon ""}
                                                                  :undone {:enabled true
                                                                           :icon "×"}}}}}
                    :core.norg.dirman {:config {:workspaces {:nodo "~/notes/todo"}}}
                    ;:core.integrations.telescope {}
                    }}))}

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
 :run ":GlowInstall"
 :setup (λ []
           (local prefix ((. (require :kaza.map) :prefix-o) :<space>g :glow))
           (prefix.map :n :f "<cmd>Glow<cr>" "show preview")
          )
 }

;; color
:Shougo/unite.vim
:ujihisa/unite-colorscheme
:altercation/vim-colors-solarized   ; solarized
:croaker/mustang-vim                ; mustang
:jeffreyiacono/vim-colors-wombat    ; wombat
:nanotech/jellybeans.vim            ; jellybeans
:vim-scripts/Lucius                 ; lucius
:vim-scripts/Zenburn                ; zenburn
:mrkn/mrkn256.vim                   ; mrkn256
:jpo/vim-railscasts-theme           ; railscasts
:therubymug/vim-pyte                ; pyte
:tomasr/molokai                     ; molokai
:chriskempson/vim-tomorrow-theme    ; tomorrow night
:vim-scripts/twilight               ; twilight
:w0ng/vim-hybrid                    ; hybrid
:freeo/vim-kalisi                   ; kalisi
:morhetz/gruvbox                    ; gruvbox
:toupeira/vim-desertink             ; desertink
:sjl/badwolf                        ; badwolf
:itchyny/landscape.vim              ; landscape
:joshdick/onedark.vim               ; onedark in atom
:gosukiwi/vim-atom-dark             ; atom-dark
:liuchengxu/space-vim-dark          ; space-vim-dark
:kristijanhusak/vim-hybrid-material ; hybrid_material
:drewtempelmeyer/palenight.vim      ; palenight
:haishanh/night-owl.vim             ; night owl
:arcticicestudio/nord-vim           ; nord
:cocopon/iceberg.vim                ; iceberg
:hzchirs/vim-material               ; vim-material
:relastle/bluewery.vim              ; bluewery
:mhartington/oceanic-next           ; OceanicNext
:nightsense/snow                    ; snow
:folke/tokyonight.nvim
:Mangeshrex/uwu.vim                 ; uwu
:ulwlu/elly.vim                     ; elly
:michaeldyrynda/carbon.vim
]
