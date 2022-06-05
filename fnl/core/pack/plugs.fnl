(import-macros {: req-f : ref-f : epi : ep} :util.macros)
(import-macros {: nmaps : map : cmd : plug : space : ui-ignore-filetype : la : br : let-g} :kaza.macros)

(macro au [group event body]
  `(vim.api.nvim_create_autocmd ,event {:callback (λ [] ,body) :group (vim.api.nvim_create_augroup ,group {:clear true})}))

[
;;; snippet

:SirVer/ultisnips
:honza/vim-snippets

;;; UI

{1 :kyazdani42/nvim-web-devicons
 :config (λ [] ((req-f :set_icon :nvim-web-devicons) {:fnl {:icon "🌱" :color "#428850" :name :fnl}}))}
{1 :kyazdani42/nvim-tree.lua
 :requires :kyazdani42/nvim-web-devicons
 :disabe true
 :config (λ []
           ((req-f :setup :nvim-tree) {:actions {:open_file {:quit_on_open true}}})
           (nmaps
             :<space>n
             :nvim-tree
             [[:t (cmd :NvimTreeToggle) :toggle]
              [:r (cmd :NvimTreeRefresh) :refresh]
              [:f (cmd :NvimTreeFindFile) :find]]))}
; {1 :nvim-neo-tree/neo-tree.nvim
;  :branch :v2.x
;  :requires [:nvim-lua/plenary.nvim
;             :kyazdani42/nvim-web-devicons
;             :MunifTanjim/nui.nvim]}
{1 :glepnir/dashboard-nvim
 :disable true
 :config (λ [] (tset vim.g :dashboard_default_executive :telescope))}
{1 :rinx/nvim-minimap
 :config (λ []
           (vim.cmd "let g:minimap#window#width = 10")
           (vim.cmd "let g:minimap#window#height = 35"))}

;; scrollbar
{1 :petertriho/nvim-scrollbar
 :config (λ [] ((req-f :setup :scrollbar) {:excluded_buftypes [:terminal]
                                           :excluded_filetypes (ui-ignore-filetype)}))}

;; status line
; {1 :b0o/incline.nvim
;  :config (la (ref-f :setup :incline))}
; {1 :feline-nvim/feline.nvim
;  :setup (la (ref-f :setup :feline)
;              ((-> (require :feline) (. :winbar) (. setup))))}
; {1 :nvim-lualine/lualine.nvim
;  :config (la (ref-f :setup :lualine {:options {:globalstatus true}}))
;  :requires {1 :kyazdani42/nvim-web-devicons
;             :opt true }}


{1 :edluffy/specs.nvim
 :config (la ((req-f :setup :specs) {:show_jumps true
                                     :min_jump 10
                                     :popup {:delay_ms 0
                                             :inc_ms 10
                                             :blend 10
                                             :width 50
                                             :winhl :Pmenu
                                             :fader (let [specs (require :specs)]
                                                      (. specs :linear_fader))
                                             :resizer (let [specs (require :specs)]
                                                        (. specs :shrink_resizer))}
                                     :ignore_filetypes []
                                     :ignore_buftypes {:nofile true}}))
 }

{1 :nvim-telescope/telescope.nvim
 :requires [:nvim-lua/plenary.nvim]
 :setup (λ []
          (local prefix ((. (require :kaza.map) :prefix-o) :n :<space>t :telescope))
          (prefix.map :f "<cmd>Telescope find_files<cr>" "find files")
          (prefix.map :g "<cmd>Telescope live_grep<cr>" "live grep")
          (prefix.map :b "<cmd>Telescope buffers<cr>" "buffers")
          (prefix.map :h "<cmd>Telescope help_tags<cr>" "help tags")
          (prefix.map :t "<cmd>Telescope<cr>" "telescope")
          (prefix.map :o "<cmd>Telescope oldfiles<cr>" "old files")
          (prefix.map :r "<cmd>Telescope file_browser<cr>" "file_browser"))}

{1 :nvim-telescope/telescope-file-browser.nvim
 :config (la ((req-f :load_extension :telescope) :file_browser))
 :requires [:nvim-telescope/telescope.nvim]}

{1 :nvim-telescope/telescope-packer.nvim
 :config (la ((req-f :load_extension :telescope) :packer))
 :requires [:nvim-telescope/telescope.nvim]}

{1 :nvim-telescope/telescope-frecency.nvim
 :config (la ((req-f :load_extension :telescope) :frecency))
 :requires [:tami5/sqlite.lua :nvim-telescope/telescope.nvim]}

{1 :xiyaowong/nvim-transparent
 :config (λ []
           ((-> (require :transparent) (. :setup))
            {:enable false}))}
{1 :akinsho/bufferline.nvim
 :tag :*
 :requires :kyazdani42/nvim-web-devicons
 :config (λ [] (ref-f :setup :bufferline))
 :setup (la (nmaps
              :<space>b
              :bufferline
              [[(br :r) (cmd :BufferLineCycleNext) "next"]
               [(br :l) (cmd :BufferLineCyclePrev) "prev"]
               [:e (cmd :BufferLineSortByExtension) "sort by extension"]
               [:d (cmd :BufferLineSortByDirectory) "sort by directory"]
               ]))}
:sheerun/vim-polyglot
{1 :nvim-treesitter/nvim-treesitter
 :run ":TSUpdate"
 :requires :p00f/nvim-ts-rainbow
 :config (λ []
           ((. (require :orgmode) :setup_ts_grammar))
           ((. (require "nvim-treesitter.configs") :setup)
            {:ensure_installed "maintained"
             :sync_install false
             :ignore_install [ "javascript" ]
             :highlight {:enable false
                         :disable [ "c" "rust" "org" "vim" "tex"]
                         :additional_vim_regex_highlighting ["org"]}
             :ensure_installed ["org"]
             :rainbow {:enable true
                       :extended_mode true
                       :max_file_lines nil}}))}
{1 :norcalli/nvim-colorizer.lua
 :config (λ []
           ((. (require :colorizer) :setup)))}

; {1 :mattn/ctrlp-matchfuzzy
;  :setup (λ []
;           (tset g :ctrlp_match_func {:match :ctrlp_matchfuzzy#matcher}))}
{1 :ctrlpvim/ctrlp.vim
 :setup (λ []
          (local g vim.g)
          (tset g :ctrlp_map :<Nop>)
          (tset g :ctrlp_working_path_mode :ra)
          (tset g :ctrlp_open_new_file :r)
          (tset g :ctrlp_extensions [:tag :quickfix :dir :line :mixed])
          (tset g :ctrlp_match_window "bottom,order:btt,min:1,max:18")
          (nmaps
            :<space>p
            :ctrlp
            [[:a ::<c-u>CtrlP<Space> :default]
             [:b :<cmd>CtrlPBuffer<cr> :buffer]
             [:d :<cmd>CtrlPDir<cr> "directory"]
             [:f :<cmd>CtrlP<cr> "all files"]
             [:l :<cmd>CtrlPLine<cr> "grep in a current file"]
             [:m :<cmd>CtrlPMRUFiles<cr> "file history"]
             [:q :<cmd>CtrlPQuickfix<cr> "quickfix"]
             [:s :<cmd>CtrlPMixed<cr> "file and buffer"]
             [:t :<cmd>CtrlPTag<cr> "tag"]]))}

; Show git status on left of a code.
{1 :lewis6991/gitsigns.nvim
 :requires :nvim-lua/plenary.nvim
 :config (λ []
           ((. (require :gitsigns) :setup)
            {:current_line_blame true}))}

{1 :kana/vim-submode
 :config (λ []
           ((. vim.fn :submode#enter_with) :bufmove :n "" :<space>s> :<C-w>>)
           ((. vim.fn :submode#enter_with) :bufmove :n "" :<space>s< :<C-w><)
           ((. vim.fn :submode#enter_with) :bufmove :n "" :<space>s+ :<C-w>+)
           ((. vim.fn :submode#enter_with) :bufmove :n "" :<space>s- :<C-w>-)
           ((. vim.fn :submode#map) :bufmove :n "" :> :<C-w>>)
           ((. vim.fn :submode#map) :bufmove :n "" :< :<C-w><)
           ((. vim.fn :submode#map) :bufmove :n "" :+ :<C-w>+)
           ((. vim.fn :submode#map) :bufmove :n "" :- :<C-w>-))}

;;; lsp

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
 :cmd :CodeActionMenu
 :setup (λ []
          (let [prefix ((. (require :kaza.map) :prefix-o) :n :<space>f :code-action-menu)]
            (prefix.map "" "<cmd>CodeActionMenu<cr>" :action)))}

;; error list
{1 :folke/trouble.nvim
 :requires :yazdani42/nvim-web-devicons
 :config (λ [] ((-> (require :trouble) (. :setup)) {}))}

;; cmp plugins
{1 :hrsh7th/nvim-cmp
 :requires [:hrsh7th/cmp-buffer       ; buffer completions
            :hrsh7th/cmp-path         ; path completions
            :hrsh7th/cmp-nvim-lsp
            :hrsh7th/cmp-nvim-lua
            :hrsh7th/cmp-cmdline      ; cmdline completions
            :hrsh7th/cmp-calc
            :hrsh7th/cmp-nvim-lsp-document-symbol
            :nvim-orgmode/orgmode
            :quangnguyen30192/cmp-nvim-ultisnips
            :neovim/nvim-lspconfig]
 :config (λ []
           (local cmp (require :cmp))
           (cmp.setup
             {:snippet {:expand (λ [args]
                                  (vim.fn.UltiSnips#Anon args.body))}
              :sources (cmp.config.sources
                         [{:name :ultisnips}
                          {:name :copilot :group_index 2}
                          {:name :nvim_lsp}
                          {:name :orgmode}
                          {:name :lsp_document_symbol}]
                         [{:name :buffer
                           :option {:get_bufnrs (λ []
                                                  (vim.api.nvim_list_bufs))}}])
              :mapping (cmp.mapping.preset.insert
                         {:<tab> (cmp.mapping (λ [fallback]
                                                (if
                                                  (cmp.visible)
                                                  (cmp.select_next_item)
                                                  (let [(line col) (unpack (vim.api.nvim_win_get_cursor 0))]
                                                    (and (not= col 0)
                                                         (= (-> (vim.api.nvim_buf_get_lines 0 (- line 1) line true)
                                                                (. 1)
                                                                (: :sub col col)
                                                                (: :match :%s))
                                                            nil)))
                                                  (cmp.mapping.complete)
                                                  (fallback))))
                          :<c-e> (cmp.mapping.abort)
                          :<cr> (cmp.mapping.confirm {:select false})
                          })})
           (cmp.setup.cmdline :/ {:mapping (cmp.mapping.preset.cmdline)
                                  :sources [{:name :buffer}]})
           (cmp.setup.cmdline :: {:mapping (cmp.mapping.preset.cmdline)
                                  :sources (cmp.config.sources [{:name :path}] [{:name :cmdline}])}))}

;; highlighting other uses of the current word under the cursor
{1 :RRethy/vim-illuminate}


{1 :neovim/nvim-lspconfig
 :config (λ []
           (local ˜capabilities ((. (require :cmp_nvim_lsp) :update_capabilities) (vim.lsp.protocol.make_client_capabilities)))
           (each [_ key (ipairs [:rust_analyzer])]
             ((-> (require :lspconfig) (. key) (. :setup))
              {:capabilities capabilities
               :diagnostics {:enable true
                             :disabled [:unresolved-proc-macro]
                             :enableExperimental true}}))
           ((-> (require :lspconfig) (. :gopls) (. :setup))
            {:on_attach (lambda [client]
                          (ref-f :on_attach :illuminate client))}))}

{1 :tami5/lspsaga.nvim
 :config (λ [] ((. (require :lspsaga) :setup)
                {:code_action_prompt {:virtual_text false}}))}

;; show type of argument
{1 :ray-x/lsp_signature.nvim
 :config (λ [] ((. (require :lsp_signature) :setup) {}))}

;; tagbar alternative
:simrat39/symbols-outline.nvim
{1 :stevearc/aerial.nvim
 :config (λ []
           ((req-f :setup :aerial) {:on_attach (λ [bufnr]
                                                 (let [prefix ((. (require :kaza.map) :prefix-o ) :n :<space>a :aerial)]
                                                   (prefix.map-buf bufnr :n "t" (cmd :AerialToggle!) :JumpForward)
                                                   (prefix.map-buf bufnr :n "{" (cmd :AerialPrev) :JumpForward)
                                                                              (prefix.map-buf bufnr :n "}" (cmd :AerialNext) :JumpBackward)
                                                   (prefix.map-buf bufnr :n "[[" (cmd :AerialPrevUp) :JumpUpTheTree)
                                                                               (prefix.map-buf bufnr :n "]]" (cmd :AerialNextUp) :JumpUpTheTree)))}))}
{1 :sidebar-nvim/sidebar.nvim
 :requires [:jremmen/vim-ripgrep]
 :config (la
           (local section {:title :Environment
                           :icon :
                           :setup (lambda [ctx]
                                    nil)
                           :update (lambda [ctx]
                                     nil)
                           :draw (lambda [ctx]
                                   "> string here\n> multiline")
                           :heights {:groups {:MyHighlightGroup {:gui :#C792EA :fg :#ff0000 :bg :#00ff00}}
                                     :links {:MyHighlightLink :Keyword}}})
           (ref-f
               :setup
               :sidebar-nvim
               {:initial_width 21
                :sections [:datetime section :git :todos :buffers :files :symbols :diagnostics ]
                :todos {:icon :
                        :ignored_paths ["~"]
                        :initially_closed true}}))
 :setup (la
           (nmaps
             :<space>i
             :sidebar
             [[:t (cmd :SidebarNvimToggle) :toggle]
              [:f (cmd :SidebarNvimFocus) :focus]]))
 :rocks [:luatz]}

{1 :hrsh7th/vim-vsnip
 :disable true
 :requires [:hrsh7th/vim-vsnip-integ
            :rafamadriz/friendly-snippets]}

;;; runner
{1 :michaelb/sniprun
 :run "bash install.sh"}
{1 :thinca/vim-quickrun
 :setup (λ []
          (map :n :<space>or (cmd :QuickRun) "[others] quickrun")) }


;;; copilot
:github/copilot.vim
{1 :zbirenbaum/copilot.lua
 :event [:VimEnter]
 :config (la (vim.defer_fn
               (la (ref-f :setup :copilot))
               100))}
{1 :zbirenbaum/copilot-cmp
 :after ["copilot.lua" "nvim-cmp"]}

;;; vim
{1 :Shougo/echodoc.vim
 :setup (λ []
          (tset vim.g :echodoc#enable_at_startup true)
          (tset vim.g :echodoc#type :floating))}

;; thank you tpope
{1 :tpope/vim-fugitive
 :setup (λ []
          (let [ prefix ((. (require :kaza.map) :prefix-o) :n "<space>g" :git)]
            (prefix.map "g" "<cmd>Git<cr>" "add")
            (prefix.map "c" "<cmd>Git commit<cr>" "commit")
            (prefix.map "p" "<cmd>Git push<cr>" "push")))}
:tpope/vim-rhubarb ; enable :Gbrowse
:tpope/vim-commentary
:tpope/vim-unimpaired
:tpope/vim-surround
:tpope/vim-abolish
; {1 :tpope/vim-rsi ; insert mode extension
   ;  :config (la (tset vim.g :rsi_non_meta true))}
:vim-utils/vim-husk
:tpope/vim-repeat
:tpope/vim-sexp-mappings-for-regular-people
{1 :guns/vim-sexp
 :setup (λ []
          (tset vim.g :sexp_filetypes "clojure,scheme,lisp,timl,fennel")
          (tset vim.g :sexp_enable_insert_mode_mappings false))}

;;; util
; {1 :Cassin01/hyper-witch.nvim
;  :setup (λ []
;           (tset vim.g :hwitch#prefixes _G.__kaza.prefix))}

{1 :majutsushi/tagbar
 :setup (λ []
          (tset vim.g :tagbar_type_fennel {:ctagstype :fennel
                                           :sort 0
                                           :kinds ["f:functions" "v:variables" "m:macros" "c:comments"]})
          ((. ((. (require :kaza.map) :prefix-o) :n :<space>a :tagbar) :map)
           :t :<cmd>TagbarToggle<cr> :toggle))}
{1 :tyru/open-browser.vim
 :config (λ []
           (local prefix ((. (require :kaza.map) :prefix-o) :n :<leader>s :open-browser))
           (prefix.map "" "<Plug>(openbrowser-smart-search)" "search")
           (map :v "<leader>s" "<Plug>(openbrowser-smart-search)" "search"))}
{1 :mbbill/undotree
 :setup (λ []
          ((. ((. (require :kaza.map) :prefix-o) :n :<space>u :undo-tree) :map)
           :t :<cmd>UndotreeToggle<cr> :toggle))}
{1 :junegunn/vim-easy-align
 :setup (λ []
          (let [prefix ((. (require :kaza.map) :prefix-o) :n :<space>ea :easy-align)]
            (prefix.map "" "<Plug>(EasyAlign)" :align))
          (map :x "<space>ea" "<Plug>(EasyAlign)" :align)) }
:terryma/vim-multiple-cursors
; :rhysd/clever-f.vim
:Jorengarenar/vim-MvVis ; Move visually selected text. Ctrl-HLJK
{1 :terryma/vim-expand-region
 :setup (λ []
          (vim.cmd "vmap v <Plug>(expand_region_expand)")
          (vim.cmd "vmap <C-v> <Plug>(expand_region_shrink)"))}

{1 :ggandor/leap.nvim
 :config (λ [] (ref-f :set_default_keymaps :leap))}

;; move dir to dir
{1 :francoiscabrol/ranger.vim
 :requires :rbgrouleff/bclose.vim
 :setup (λ []
          (let [prefix ((. (require :kaza.map) :prefix-o) :n :<space>r :ranger)]
            (prefix.map :r :<cmd>Ranger<cr> "start at here")
            (prefix.map :t :<cmd>RangerNewTab<cr> "new tab")))}

;;; move
{1 :Shougo/vimproc.vim
 :run "make"}

;; Jump to any visible line in the buffer by using letters instead of numbers.
{1 :skamsie/vim-lineletters
 :setup (λ []
          (let [prefix ((. (require :kaza.map) :prefix-o) :n :<space>l :lineletters)]
            (prefix.map "" "<Plug>LineLetters" "jump to line"))) }

;; mark
:kshenoy/vim-signature

:mhinz/neovim-remote

;; Plugin to help me stop repeating the basic movement key.
{1 :takac/vim-hardtime
 :config (la (let-g hardtime_showmsg false)
             (let-g hardtime_default_on false))}

{1 :notomo/cmdbuf.nvim
 :config (λ []
           ;;; FIXME I don't know how to declare User autocmd.
           (nmaps :q :cmdbuf [[:: (λ [] ((req-f :split_open :cmdbuf) vim.o.cmdwinheight)) "cmdbuf"]
                              [:l (λ [] ((. (require :cmdbuf) :split_open) vim.o.cmdwinheight {:type :lua/cmd})) "lua"]
                              [:/ (λ [] ((req-f :split_open :cmdbuf) vim.o.cmdwinheight {:type :vim/search/forward})) :search-forward]
                              ["?" (λ [] ((. (require :cmdbuf) :split_open) vim.o.cmdwinheight {:type :vim/search/backward})) :search-backward]]))}

;; translation
{1 :skanehira/translate.vim
 :setup (λ []
          (vim.cmd "nnoremap gr <Plug>(Translate)")
          (vim.cmd "vnoremap <c-t> :Translate<cr>"))}

;; zen
:junegunn/limelight.vim
:junegunn/goyo.vim
:amix/vim-zenroom2

;; web browser
{1 :thinca/vim-ref
 :setup (la (vim.cmd "source ~/.config/nvim/fnl/core/pack/conf/vim-ref.vim"))}

;;; language

; ;; deno
; :vim-denops/denops.vim
; {1 :Cassin01/fetch-info.nvim
;  :require :ms-jpq/lua-async-await
;  :setup (λ []
;           (local a (require :plug.async))
;           (local {: u-cmd} (require :kaza))
;           (u-cmd :MyGetInfo (la
;                               (lambda []
;                                 (a.sync
;                                   (lambda []
;                                     (vim.cmd :GInfoF)))))))}


;; text
{1 :sedm0784/vim-you-autocorrect
 :setup (λ []
          (let [prefix ((. (require :kaza.map) :prefix-o) :n :<space>a :auto-collect)]
            (prefix.map "e" "<cmd>EnableAutocorrect<cr>" "enable auto correct")))}

;; org
{1 :nvim-orgmode/orgmode
 :config (λ []
           ((. (require :orgmode) :setup) {:org_agenda_files ["~/org/*"]}))}

;; lua
:bfredl/nvim-luadev

;; fennel
:bakpakin/fennel.vim  ; syntax
:jaawerth/fennel-nvim ; native fennel support
:Olical/conjure       ; interactive environment
:Olical/nvim-local-fennel

;; rust
:rust-lang/rust.vim

;; tex
{1 :Cassin01/texrun.vim
 :setup (λ [] (tset vim.g :texrun#file_name [:l02.tex :sample.tex]))}

;; vim
{1 :LeafCage/vimhelpgenerator
 :setup (λ []
          (tset vim.g :vimhelpgenerator_defaultlanguage "en")
          (tset vim.g :vimhelpgenerator_version :0.0.1)
          (tset vim.g :vimhelpgenerator_contents {:contents true
                                                  :introduction true
                                                  :usage true
                                                  :interface true
                                                  :variables true
                                                  :commands true
                                                  :key-mappings true
                                                  :functions true
                                                  :setting true
                                                  :todo true
                                                  :changelog false}))} ; doc generator

;; markdown
:godlygeek/tabular
:preservim/vim-markdown
{1 :iamcco/markdown-preview.nvim
 :run "cd app & yarn install"
 :setup (λ []
          (tset vim.g :mkdp_filetypes [:markdown])
          (tset vim.g :mkdp_auto_close false)
          (tset vim.g :mkdp_preview_options {:katex {}
                                             :disable_sync_scroll false})
          (local prefix ((. (require :kaza.map) :prefix-o) :n :<space>om :markdown-preview))
          (prefix.map :p :<Plug>MarkdownPreview "preview"))
 :ft [:markdown]}
{1 :ellisonleao/glow.nvim
 :cmd [:Glow :GlowInstall]
 :run ":GlowInstall"
 :setup (λ []
          (local prefix ((. (require :kaza.map) :prefix-o) :n "<space>g" :glow))
          (prefix.map :mp "<cmd>Glow<cr>" "preview"))}

;; japanese
:deton/jasegment.vim

;; color
:Shougo/unite.vim
:ujihisa/unite-colorscheme
; :altercation/vim-colors-solarized   ; solarized
; :croaker/mustang-vim                ; mustang
; :jeffreyiacono/vim-colors-wombat    ; wombat
; :nanotech/jellybeans.vim            ; jellybeans
; :vim-scripts/Lucius                 ; lucius
; :vim-scripts/Zenburn                ; zenburn
; :mrkn/mrkn256.vim                   ; mrkn256
; :jpo/vim-railscasts-theme           ; railscasts
; :therubymug/vim-pyte                ; pyte
; :tomasr/molokai                     ; molokai
; :chriskempson/vim-tomorrow-theme    ; tomorrow night
; :vim-scripts/twilight               ; twilight
; :w0ng/vim-hybrid                    ; hybrid
; :freeo/vim-kalisi                   ; kalisi
; :morhetz/gruvbox                    ; gruvbox
; :toupeira/vim-desertink             ; desertink
; :sjl/badwolf                        ; badwolf
; :itchyny/landscape.vim              ; landscape
; :joshdick/onedark.vim               ; onedark in atom
; :gosukiwi/vim-atom-dark             ; atom-dark
; :liuchengxu/space-vim-dark          ; space-vim-dark
; :kristijanhusak/vim-hybrid-material ; hybrid_material
; :drewtempelmeyer/palenight.vim      ; palenight
; :haishanh/night-owl.vim             ; night owl
; :arcticicestudio/nord-vim           ; nord
; :cocopon/iceberg.vim                ; iceberg
; :hzchirs/vim-material               ; vim-material
; :relastle/bluewery.vim              ; bluewery
; :mhartington/oceanic-next           ; OceanicNext
; :nightsense/snow                    ; snow
:folke/tokyonight.nvim
; :Mangeshrex/uwu.vim                 ; uwu
; :ulwlu/elly.vim                     ; elly
; :michaeldyrynda/carbon.vim
; :rafamadriz/neon
]
