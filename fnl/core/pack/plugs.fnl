(import-macros {: req-f} :util.macros)

(macro au [group event body]
  `(vim.api.nvim_create_autocmd ,event {:callback (λ [] ,body) :group (vim.api.nvim_create_augroup ,group {:clear true})}))


( macro nmap-buf [key cmd desc]
  `(vim.api.nvim_buf_set_keymap 0 :n ,key ,cmd {:noremap true :silent true :desc ,desc}))

(macro nmap [key cmd desc]
  `(vim.api.nvim_set_keymap :n ,key ,cmd {:noremap true :silent true :desc ,desc}))

(macro nmaps [prefix desc tbl]
  `(let [prefix# ((. (require :kaza.map) :prefix-o) :n ,prefix ,desc)]
     (each [_# l# (ipairs ,tbl)]
       (prefix#.map-f (unpack l#)))))

(macro user-cmd [name cmd]
  `(vim.api.nvim_add_user_command ,name ,cmd {}))


(macro cmd [s] (string.format "<cmd>%s<cr>" s))

(macro p+ [name opt]
  (when (not (-?> opt (. :disable)))
     `(let [opt# ,opt]
       (tset opt# 1 ,name)
       (table.insert plugs opt#))))

(macro cleaner [tbl]
  "speed upped 5.6ms (with 9 disabled plugins)"
  (icollect [_# k# (ipairs tbl)]
            (when (not (-?> k# (. :disable)))
              k#)))



(let [plugs (cleaner [
 ;;; snippet
 :lewis6991/impatient.nvim

 :SirVer/ultisnips
 :honza/vim-snippets

 ;;; UI

 {1 :Shougo/ddu.vim
  :disable true
  :requires [:vim-denops/denops.vim
             ; filter
             :Shougo/ddu-filter-matcher_substring
             ; ui
             :Shougo/ddu-ui-ff
             :Shougo/ddu-ui-filer
             ; kind
             :Shougo/ddu-kind-file
             ; source
             :Shougo/ddu-commands.vim
             :Shougo/ddu-source-file
             :Shougo/ddu-source-file_rec
             :Shougo/ddu-source-register
             :kuuote/ddu-source-mr
             :lambdalisue/mr.vim
             :shun/ddu-source-buffer
             :4513ECHO/ddu-source-colorscheme
             ]
  :config (λ []
            ((. vim.fn :ddu#custom#patch_global)
             {:ui :ff
              :sources [{:name :file_rec :params {}}
                        {:name :mr}
                        {:name :file}
                        {:name :register}
                        {:name :buffer}]
              :sourceOptions [:_ {:matchers [:matcher_substring]}]
              :kindOptions {:file {:defaultAction :open}
                            :colorscheme {:defaultAction :set}}
              :uiParams {:ff { :startFilter false }}
              :filterParams {:matcher_substring {:highlightMatched :Search}}})
            (vim.api.nvim_create_autocmd
              :FileType
              {:pattern :ddu-ff
               :group (vim.api.nvim_create_augroup :ddu-ff {:clear true})
               :callback (λ []
                           (nmap-buf :<cr> (cmd "ddu#ui#ff#do_action('itemAction')")  "item action")
                           (vim.api.nvim_buf_set_keymap 0
                                                        :n
                                                        :<space>
                                                        "<Cmd>call ddu#ui#ff#do_action('toggleSelectItem')<CR>" {:noremap true :silent true :desc "toggle select item"})
                           (vim.api.nvim_buf_set_keymap 0
                                                        :n
                                                        :i
                                                        "<Cmd>call ddu#ui#ff#do_action('openFilterWindow')<CR>" {:noremap true :silent true :desc "open filter window" })
                           (vim.api.nvim_buf_set_keymap 0
                                                        :n
                                                        :q
                                                        "<Cmd>call ddu#ui#ff#do_action('quit')<CR>" {:noremap true :silent true :desc "quit" })
                           )})
            (vim.api.nvim_create_autocmd
              :FileType
              {:pattern :ddu-ff-filter
               :group (vim.api.nvim_create_augroup :ddu-ff-filter {:clear true})
               :callback (λ []
                           (vim.api.nvim_buf_set_keymap 0
                                                        :i
                                                        :<cr>
                                                        "ddu#ui#filer#is_directory() ? <cmd>call ddu#ui#filer#do_action('itemAction', {'name': 'narrow'})<cr> : <cmd>call ddu#ui#filer#do_action('itemAction', {'name': 'open'})<cr>"
                                                        {:noremap true :silent true :desc :action: :expr true})
                           (vim.api.nvim_buf_set_keymap 0 :n :<cr> :<cmd>close<cr> {:noremap true :silent true :desc :close})
                           (vim.api.nvim_buf_set_keymap 0 :n :q :<cmd>close<cr> {:noremap true :silent true :desc :close}))})
            (let [prefix ((. (require :kaza.map) :prefix-o) :n :<space>d :ddu)]
              (prefix.map :m "<cmd>Ddu mr<cr>" :history)
              (prefix.map :b "<cmd>Ddu buffer<cr>" :buffer)
              (prefix.map :r "<cmd>Ddu register<cr>" :register)
              (prefix.map :n "<cmd>Ddu file -source-param-new -volatile<cr>" "new file")
              (prefix.map :f "<cmd>Ddu file<cr>" :file)
              (prefix.map :c "<cmd>Ddu colorscheme<cr>" :colorscheme))
            )}

 {1 :preservim/nerdtree
  :requires :ryanoasis/vim-devicons
  :setup (λ []
           (local nerdtree ((req-f :prefix-o :kaza.map) :n :<space>n :nerdtree))
           ;(local nerdtree ((. (require :kaza.map) :prefix-o) :n :<space>n :nerdtree))
           (nerdtree.map :c :<cmd>NERDTreeCWD<CR> "cwd")
           (nerdtree.map :t :<cmd>NERDTreeToggle<CR> "toggle")
           (nerdtree.map :f :<cmd>NERDTreeFind<CR> "find"))}
 {1 :glepnir/dashboard-nvim
  :disable true
  :config (λ [] (tset vim.g :dashboard_default_executive :telescope))}
 {1 :rinx/nvim-minimap
  :config (λ []
            (vim.cmd "let g:minimap#window#width = 10")
            (vim.cmd "let g:minimap#window#height = 35"))}
 {1 :nvim-telescope/telescope.nvim
  :requires [:nvim-lua/plenary.nvim ]
  :setup (λ []
           (local prefix ((. (require :kaza.map) :prefix-o) :n :<space>t :telescope))
           (prefix.map :f "<cmd>Telescope find_files<cr>" "find files")
           (prefix.map :g "<cmd>Telescope live_grep<cr>" "live grep")
           (prefix.map :b "<cmd>Telescope buffers<cr>" "buffers")
           (prefix.map :h "<cmd>Telescope help_tags<cr>" "help tags")
           (prefix.map :t "<cmd>Telescope<cr>" "telescope")
           (prefix.map :o "<cmd>Telescope oldfiles<cr>" "old files"))}
{1 :xiyaowong/nvim-transparent
 :disable true
 :config (λ []
           ((-> (require :transparent) (. :setup))
            {:enable false}))}
{1 :akinsho/bufferline.nvim
 :requires :kyazdani42/nvim-web-devicons}
{1 :windwp/windline.nvim
 :disable true
 :config (λ [] (require "wlsample.vscode")
           ((. (require "wlfloatline") :setup)
            {:always_active false
             :show_last_status false}))}

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
             :highlight {:enable true
                         :disable [ "c" "rust" "org"]
                         :additional_vim_regex_highlighting ["org"]}
             :ensure_installed ["org"]
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
          (local ctrlp ((. (require :kaza.map) :prefix-o) :n :<space>p :ctrlp))
          (ctrlp.map :a ::<c-u>CtrlP<Space> :default)
          (ctrlp.map :b :<cmd>CtrlPBuffer<cr> :buffer)
          (ctrlp.map :d :<cmd>CtrlPDir<cr> "directory")
          (ctrlp.map :f :<cmd>CtrlP<cr> "all files")
          (ctrlp.map :l :<cmd>CtrlPLine<cr> "grep in a current file")
          (ctrlp.map :m :<cmd>CtrlPMRUFiles<cr> "file history")
          (ctrlp.map :q :<cmd>CtrlPQuickfix<cr> "quickfix")
          (ctrlp.map :s :<cmd>CtrlPMixed<cr> "file and buffer")
          (ctrlp.map :t :<cmd>CtrlPTag<cr> "tag"))}

;; Show git status on left of a code.
; {1 :lewis6991/gitsigns.nvim
;  :requires :nvim-lua/plenary.nvim
;  :config (λ []
;            ((. (require :gitsigns) :setup)
;             {:current_line_blame true}))}

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


;; cmp plugins
{1 :hrsh7th/nvim-cmp
 :requires [:hrsh7th/cmp-buffer       ; buffer completions
            :hrsh7th/cmp-path         ; path completions
            :hrsh7th/cmp-nvim-lsp
            :hrsh7th/cmp-nvim-lua
            :hrsh7th/cmp-cmdline      ; cmdline completions
            :hrsh7th/cmp-calc
            :nvim-orgmode/orgmode
            :quangnguyen30192/cmp-nvim-ultisnips
            :neovim/nvim-lspconfig]
 :config (λ []
           (local cmp (require :cmp))
           (cmp.setup {:snippet {:expand (λ [args]
                                           (vim.fn.UltiSnips#Anon args.body))}
                       :sources (cmp.config.sources [{:name :ultisnips} {:name :nvim_lsp} {:name :orgmode}]
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

{1 :tami5/lspsaga.nvim
 :config (λ [] ((. (require :lspsaga) :setup)
                {:code_action_prompt {:virtual_text false}}))}

;; show type of argument
{1 :ray-x/lsp_signature.nvim
 :config (λ [] ((. (require :lsp_signature) :setup) {}))}

{1 :hrsh7th/vim-vsnip
 :disable true
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
:tpope/vim-repeat
:github/copilot.vim
:tpope/vim-sexp-mappings-for-regular-people
{1 :guns/vim-sexp
 :setup (λ []
          (tset vim.g :sexp_filetypes "clojure,scheme,lisp,timl,fennel")
          (tset vim.g :sexp_enable_insert_mode_mappings false))}

;; util

{1 :majutsushi/tagbar
 :setup (λ []
          (tset vim.g :tagbar_type_fennel {:ctagstype :fennel
                                           :sort 0
                                           :kinds ["f:functions" "v:variables" "m:macros"]})
          ((. ((. (require :kaza.map) :prefix-o) :n :<space>a :tagbar) :map)
           :t :<cmd>TagbarToggle<cr> :toggle))}


{1 :tyru/open-browser.vim
 :config (λ []
           (local prefix ((. (require :kaza.map) :prefix-o) :n :<leader>s :open-browser))
           (prefix.map "" "<Plug>(openbrowser-smart-search)" "search")
           (local {: map} (require :kaza.map))
           (map :v "<leader>s" "<Plug>(openbrowser-smart-search)" "search"))}
{1 :mbbill/undotree
 :setup (λ []
          ((. ((. (require :kaza.map) :prefix-o) :n :<space>u :undo-tree) :map)
           :t :<cmd>UndotreeToggle<cr> :toggle))}
{1 :junegunn/vim-easy-align
 :setup (λ []
          (let [prefix ((. (require :kaza.map) :prefix-o) :n :<space>ea :easy-align)]
            (prefix.map "" "<Plug>(EasyAlign)" :align))
          (local {: map} (require :kaza.map))
          (map :x "<space>ea" "<Plug>(EasyAlign)" :align)) }
:terryma/vim-multiple-cursors
:rhysd/clever-f.vim
:Jorengarenar/vim-MvVis ; Move visually selected text. Ctrl-HLJK
{1 :terryma/vim-expand-region
 :setup (λ []
          (vim.cmd "vmap v <Plug>(expand_region_expand)")
          (vim.cmd "vmap <C-v> <Plug>(expand_region_shrink)"))}

:ggandor/lightspeed.nvim

;; move dir to dir
{1 :francoiscabrol/ranger.vim
 :requires :rbgrouleff/bclose.vim
 :setup (λ []
          (let [prefix ((. (require :kaza.map) :prefix-o) :n :<space>r :ranger)]
            (prefix.map :r :<cmd>Ranger<cr> "default")
            (prefix.map :t :<cmd>RangerNewTab<cr> "new tab")))}

;; easymotion
{1 :easymotion/vim-easymotion
 :setup (λ []
          (tset vim.g :EasyMotion_use_migemo true)
          (let [prefix ((. (require :kaza.map) :prefix-o) :n :<space>e :easy-motion)]
            (prefix.map "l" "<Plug>(easymotion-lineforward)" :l)
            (prefix.map "j" "<Plug>(easymotion-j)" :j)
            (prefix.map "k" "<Plug>(easymotion-k)" :k)
            (prefix.map "h" "<Plug>(easymotion-linebackward)" :h)))}
{1 :haya14busa/incsearch.vim
 :requires :haya14busa/incsearch-easymotion.vim
 :setup (λ []
          (vim.cmd "source ~/.config/nvim/fnl/core/pack/conf/incsearch-easymotion.vim"))}
{1 :Shougo/vimproc.vim
 :run "make"}
{1 :haya14busa/incsearch-migemo.vim
 :requires :Shougo/vimproc.vim
 :setup (λ []
          (let [prefix ((. (require :kaza.map) :prefix-o) :n :<space>i :migemo)]
            (prefix.map "/" "<Plug>(incsearch-migemo-/)" :/)
            (prefix.map "?" "<Plug>(incsearch-migemo-?)" :?)
            (prefix.map "g/" "<Plug>(incsearch-migemo-stay)" :stay)))}
{1 :haya14busa/incsearch-fuzzy.vim
 :setup (λ []
          (vim.cmd "source ~/.config/nvim/fnl/core/pack/conf/incsearch-fuzzy.vim"))}

;; Jump to any visible line in the buffer by using letters instead of numbers.
{1 :skamsie/vim-lineletters
 :setup (λ []
          (let [prefix ((. (require :kaza.map) :prefix-o) :n :<space>l :lineletters)]
            (prefix.map "" "<Plug>LineLetters" "jump to line"))) }

:kshenoy/vim-signature


:mhinz/neovim-remote

:junegunn/limelight.vim
:junegunn/goyo.vim
:amix/vim-zenroom2

;;; language

;; text
{1 :sedm0784/vim-you-autocorrect
 :setup (λ []
          (let [prefix ((. (require :kaza.map) :prefix-o) :n :<space>a :auto-collect)]
            (prefix.map "e" "<cmd>EnableAutocorrect<cr>" "enable auto correct")))}

;; org
{1 :jceb/vim-orgmode
 :disable true
 :setup (λ []
          (tset vim.g :org_agenda_files ["~/org/*.org"]))}

{1 :nvim-orgmode/orgmode
 :config (λ []
           ((. (require :orgmode) :setup) {:org_agenda_files ["~/org/*"]}))}


{1 :nvim-neorg/neorg
 :disable true
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

;; rust
:rust-lang/rust.vim

;; fennel
:bakpakin/fennel.vim  ; syntax
:jaawerth/fennel-nvim ; native fennel support
:Olical/conjure       ; interactive environment
:Olical/nvim-local-fennel

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

;; color
:Shougo/unite.vim
:ujihisa/unite-colorscheme
;:altercation/vim-colors-solarized   ; solarized
;:croaker/mustang-vim                ; mustang
;:jeffreyiacono/vim-colors-wombat    ; wombat
;:nanotech/jellybeans.vim            ; jellybeans
;:vim-scripts/Lucius                 ; lucius
;:vim-scripts/Zenburn                ; zenburn
;:mrkn/mrkn256.vim                   ; mrkn256
;:jpo/vim-railscasts-theme           ; railscasts
;:therubymug/vim-pyte                ; pyte
;:tomasr/molokai                     ; molokai
;:chriskempson/vim-tomorrow-theme    ; tomorrow night
;:vim-scripts/twilight               ; twilight
;:w0ng/vim-hybrid                    ; hybrid
;:freeo/vim-kalisi                   ; kalisi
;:morhetz/gruvbox                    ; gruvbox
;:toupeira/vim-desertink             ; desertink
;:sjl/badwolf                        ; badwolf
;:itchyny/landscape.vim              ; landscape
;:joshdick/onedark.vim               ; onedark in atom
;:gosukiwi/vim-atom-dark             ; atom-dark
;:liuchengxu/space-vim-dark          ; space-vim-dark
;:kristijanhusak/vim-hybrid-material ; hybrid_material
;:drewtempelmeyer/palenight.vim      ; palenight
;:haishanh/night-owl.vim             ; night owl
;:arcticicestudio/nord-vim           ; nord
;:cocopon/iceberg.vim                ; iceberg
;:hzchirs/vim-material               ; vim-material
;:relastle/bluewery.vim              ; bluewery
;:mhartington/oceanic-next           ; OceanicNext
;:nightsense/snow                    ; snow
:folke/tokyonight.nvim
;:Mangeshrex/uwu.vim                 ; uwu
;:ulwlu/elly.vim                     ; elly
;:michaeldyrynda/carbon.vim
;:rafamadriz/neon
])]
(p+ :stevearc/aerial.nvim
    {:config (λ []
               ((req-f :setup :aerial) {:on_attach (λ [bufnr]
                                                   (let [prefix ((. (require :kaza.map) :prefix-o ) :n :<space>a :aerial)]
                                                     (prefix.map-buf bufnr :n "t" (cmd :AerialToggle!) :JumpForward)
                                                     (prefix.map-buf bufnr :n "{" (cmd :AerialPrev) :JumpForward)
                                                     (prefix.map-buf bufnr :n "}" (cmd :AerialNext) :JumpBackward)
                                                     (prefix.map-buf bufnr :n "[[" (cmd :AerialPrevUp) :JumpUpTheTree)
                                                     (prefix.map-buf bufnr :n "]]" (cmd :AerialNextUp) :JumpUpTheTree)))}))})
(p+ :notomo/cmdbuf.nvim
    {:config (λ []
              (vim.api.nvim_add_user_command :CmdbufNew
                                             ;;; FIXME I don't know how to declare User autocmd.
                                             (λ []
                                               (vim.api.nvim_buf_set_keymap 0 :n :q (cmd :quit) {:noremap true :silent true :nowait true})
                                               (nmap-buf :dd (cmd "lua require(\"cmdbuf\").delete()") :delete)) {})
              (nmaps :q :cmdbuf [[:: (λ [] ((req-f :split_open :cmdbuf) vim.o.cmdwinheight)) "cmdbuf"]
                                 [:l (λ [] ((. (require :cmdbuf) :split_open) vim.o.cmdwinheight {:type :lua/cmd})) "lua"]
                                 [:/ (λ [] ((req-f :split_open :cmdbuf) vim.o.cmdwinheight {:type :vim/search/forward})) :search-forward]
                                 ["?" (λ [] ((. (require :cmdbuf) :split_open) vim.o.cmdwinheight {:type :vim/search/backward})) :search-backward]]))})
plugs)
