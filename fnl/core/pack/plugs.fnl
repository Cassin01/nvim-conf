(import-macros {: req-f : ref-f : epi : ep} :util.macros)
(import-macros {: nmaps : map : cmd : plug : space : ui-ignore-filetype : la : br : let-g : au!} :kaza.macros)

(macro au [group event body]
  `(vim.api.nvim_create_autocmd ,event {:callback (λ [] ,body) :group (vim.api.nvim_create_augroup ,group {:clear true})}))

(local va vim.api)

[
;;; snippet

:SirVer/ultisnips
:honza/vim-snippets

;;; UI

{1 :kyazdani42/nvim-web-devicons
 :config (λ [] ((req-f :set_icon :nvim-web-devicons) {:fnl {:icon "🌱" :color "#428850" :name :fnl}}))}
; {1 :kyazdani42/nvim-tree.lua ; INFO: startup time
;  :requires :kyazdani42/nvim-web-devicons
;  :disabe true
;  :config (λ []
;            ((req-f :setup :nvim-tree) {:actions {:open_file {:quit_on_open true}}})
;            (nmaps
;              :<space>n
;              :nvim-tree
;              [[:t (cmd :NvimTreeToggle) :toggle]
;               [:r (cmd :NvimTreeRefresh) :refresh]
;               [:f (cmd :NvimTreeFindFile) :find]]))}
; {1 :nvim-neo-tree/neo-tree.nvim
;  :branch :v2.x
;  :requires [:nvim-lua/plenary.nvim
;             :kyazdani42/nvim-web-devicons
;             :MunifTanjim/nui.nvim]}
{1 :glepnir/dashboard-nvim
 :disable true
 :config (λ [] (tset vim.g :dashboard_default_executive :telescope))}
{1 :rinx/nvim-minimap ; WARN: startup time
 :config (λ []
           (vim.cmd "let g:minimap#window#width = 10")
           (vim.cmd "let g:minimap#window#height = 35"))}

;; scrollbar
{1 :petertriho/nvim-scrollbar
 ; :event [:VimEnter]
 :config (λ [] ((req-f :setup :scrollbar) {:excluded_buftypes [:terminal]
                                           :excluded_filetypes (ui-ignore-filetype)}))}

;; status line
; {1 :b0o/incline.nvim
;  :config (la (ref-f :setup :incline))}
; {1 :feline-nvim/feline.nvim
;  :setup (la (ref-f :setup :feline)
;              ((-> (require :feline) (. :winbar) (. setup))))}
; {1 :nvim-lualine/lualine.nvim
;  :event [:VimEnter]
;  :config (la (ref-f :setup :lualine {:options {:globalstatus true}}))
;  :requires {1 :kyazdani42/nvim-web-devicons
;             :opt true }}

; notify
{1 :rcarriga/nvim-notify
 :config (lambda []
           ((. (require :notify) :setup) {:stages :fade_in_slide_out
                                        :background_colour :FloatShadow
                                        :timeout 3000 })
           (set vim.notify (require :notify)))}
{1 :folke/noice.nvim
 :event [:VimEnter]
 :config (lambda [] (ref-f :setup :noice))
 :requires [:MunifTanjim/nui.nvim :rcarriga/nvim-notify]}

{1 :anuvyklack/windows.nvim
 :requires [
            "anuvyklack/middleclass"
            "anuvyklack/animation.nvim"
            ]
 :config (lambda []
           (tset vim.o :winwidth 10)
           (tset vim.o :winminwidth 10)
           (tset vim.o :equalalways false)
           (ref-f :setup :windows)
           (vim.keymap.set :n :<C-w>z (cmd :WindowsMaximize))
           (vim.keymap.set :n :<C-w>_ (cmd :WindowsMaximizeVertically))
           (vim.keymap.set :n :<C-w>| (cmd :WindowsMaximizeHorizontally))
           (vim.keymap.set :n :<C-w>= (cmd :WindowsEqualize)))}

{1 :lukas-reineke/indent-blankline.nvim
 :config (la ((req-f :setup :indent_blankline)
              {:show_current_context true
               :show_current_context_start true
               :space_char_blankline " "}))}

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
 :event [:VimEnter]
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
 :after :telescope.nvim
 :config (la ((req-f :load_extension :telescope) :packer))
 :requires [:nvim-telescope/telescope.nvim]}

{1 :nvim-telescope/telescope-frecency.nvim
 :after :telescope.nvim
 :config (la ((req-f :load_extension :telescope) :frecency))
 :requires [:tami5/sqlite.lua :nvim-telescope/telescope.nvim]}

{1 :xiyaowong/nvim-transparent
 :cmd :TransparentEnable
 :config (λ []
           ((-> (require :transparent) (. :setup))
            {:enable false}))}
{1 :akinsho/bufferline.nvim
 :tag :*
 :requires :kyazdani42/nvim-web-devicons
 ; :config (λ []
 ;           (ref-f :setup :bufferline {:options {:separator_style :slant}}))
 :config (λ [] (ref-f :setup :bufferline {}))
 :setup (la (nmaps
              :<space>b
              :bufferline
              [[(br :r) (cmd :BufferLineCycleNext) "next"]
               [(br :l) (cmd :BufferLineCyclePrev) "prev"]
               [:e (cmd :BufferLineSortByExtension) "sort by extension"]
               [:d (cmd :BufferLineSortByDirectory) "sort by directory"]]))
 }

{1 :sheerun/vim-polyglot :opt true}
{1 :nvim-treesitter/nvim-treesitter
 :run ":TSUpdate"
 :event [:VimEnter]
 :requires {1 :p00f/nvim-ts-rainbow :after :nvim-treesitter}
 :config (λ []
           ; ((. (require :orgmode) :setup_ts_grammar))
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
; {1 :norcalli/nvim-colorizer.lua
;  :config (λ []
;            ((. (require :colorizer) :setup)))}

; {1 :haringsrob/nvim_context_vt}

;; fold
; {1 :kevinhwang91/nvim-ufo
;  :requires :kevinhwang91/promise-async
;  :setup (la (vim.cmd "UfoDetach"))
;  ; :setup (la
;  ;          ; (local capabilities (vim.lsp.protocol.make_client_capabilities))
;  ;          ; (set capabilities.textDocument.foldingRange {:dynamicRegistration true
;  ;          ;                                              :lineFoldingOnly false})
;  ;          ; (local language_servers {})
;  ;          ; (each [_ ls (ipairs language_servers)]
;  ;          ;   ((-> (require :lspconfig) (. :ls) (. :setup)) {:capabilities capabilities}))
;  ;          (ref-f :setup :ufo))
;  }

; {1 :mattn/ctrlp-matchfuzzy
;  :setup (λ []
;           (tset g :ctrlp_match_func {:match :ctrlp_matchfuzzy#matcher}))}
{1 :ctrlpvim/ctrlp.vim
 :opt true
 :cmd :CtrlP
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
{1 :lewis6991/gitsigns.nvim ; WARN startup
 :event [:VimEnter]
 :requires :nvim-lua/plenary.nvim
 :config (λ []
           ((. (require :gitsigns) :setup)
            {:current_line_blame true}))}

; {1 :sindrets/diffview.nvim :requires :nvim-lua/plenary.nvim }

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


{1 :ziontee113/icon-picker.nvim
 :requires :stevearc/dressing.nvim
 :config (λ []
           (ref-f :setup :icon-picker {:disable_legacy_commands true}))}

;;; lsp

; {1 :williamboman/nvim-lsp-installer
;  :config (λ []
;            ((. (require :nvim-lsp-installer) :on_server_ready)
;             (λ [server] (server:setup {}))))}
{1 :williamboman/mason.nvim
 :config (λ []
           (ref-f :setup :mason))
 :event [:VimEnter]
 }

{1 :onsails/lspkind-nvim
 :config (λ [] ((. (require :lspkind) :init) {}))}

; {1 "https://git.sr.ht/~whynothugo/lsp_lines.nvim"
;  :config (λ [] ((. (require :lsp_lines) :setup)))}

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
            ; :nvim-orgmode/orgmode
            {1 :uga-rosa/cmp-dictionary
             :event [:InsertEnter]
             :config (λ []
                       (local path (vim.fn.expand "~/.config/nvim/data/aspell/en.dict"))
                       (ref-f :setup :cmp_dictionary
                              {:dic 
                               {:* [:/usr/share/dict/words]
                                :spelllang {:en path}
                                }}))}
            {1 :Cassin01/cmp-gitcommit
             ; :branch :fix-shell-command_#2
             :config (λ []
                       (ref-f :setup :cmp-gitcommit
                              {:insertText (λ [val emoji] (.. val ":" emoji " "))
                               :typesDict {:build {:label :build
                                                   :emoji "🏗️"
                                                   :documentation "Changes that affect the build system or external dependencies"
                                                   :scopes [:gulp :broccoli :npm]}
                                           :chore {:label "chore"
                                                   :emoji "🤖"
                                                   :documentation "Other changes that dont modify src or test files"}
                                           :ci {:label "ci"
                                                :emoji "👷"
                                                :documentation "Changes to our CI configuration files and scripts"
                                                :scopes ["Travisi" "Circle" "BrowserStack" "SauceLabs" :Gitflow]}
                                           :docs {:label "docs"
                                                  :emoji "📚"
                                                  :documentation "Documentation only changes"}
                                           :feat {:label :feat
                                                  :emoji"✨"
                                                  :documentation "A new feature"}
                                           :fix {:label "fix"
                                                 :emoji "🐛"
                                                 :documentation "A bug fix"}
                                           :perf {:label "perf"
                                                  :emoji "⚡️"
                                                  :documentation "A code change that improves performance"}
                                           :refactor {:label "refactor"
                                                      :emoji "🧹"
                                                      :documentation "A code change that neither fixes a bug nor adds a feature"}
                                           :revert {:label "revert"
                                                    :emoji "⏪"
                                                    :documentation "Reverts a previous commit"}
                                           :style {:label "style"
                                                   :emoji "🎨"
                                                   :documentation "Changes that do not affect the meaning of the code"}
                                           :test {:label "test"
                                                  :emoji "🚨"
                                                  :documentation "Adding missing tests or correcting existing tests"}}}))}
            {1 :quangnguyen30192/cmp-nvim-ultisnips
             :config (λ [] (ref-f :setup :cmp_nvim_ultisnips {}))}
            :zbirenbaum/copilot-cmp
            :neovim/nvim-lspconfig
            ]
 :config (λ []
           (local cmp (require :cmp))
           (local lspkind (require :lspkind))
           (cmp.setup
             {:snippet {:expand (λ [args]
                                  ((. vim.fn :UltiSnips#Anon) args.body))}
              :sources (cmp.config.sources
                         [{:name :gitcommit :group_index 2}
                          {:name :copilot :group_index 2}
                          {:name :ultisnips :group_index 2}
                          {:name :nvim_lsp :group_index 2}
                          ; {:name :orgmode}
                          {:name :lsp_document_symbol}
                          {:name :skkeleton :group_index 5}
                          {:name :buffer
                           :option {:get_bufnrs (λ []
                                                  (vim.api.nvim_list_bufs))}}
                          {:name :dictionary
                           :group_index 5
                           :keyword_length 2}])
              :formatting {:format (fn [entry vim_item]
                                     ; (print (vim.inspect entry.source.name))
                                     (if (= entry.source.name :copilot)
                                       (do
                                         (tset vim_item :kind " Copilot")
                                         (tset vim_item :kind_hl_group :CmpItemKindCopilot)
                                         vim_item)
                                       (= entry.source.name :skkeleton)
                                          (do
                                            ; (tset vim_item :kind " SKK")
                                            (tset vim_item :kind " SKK")
                                            (tset vim_item :kind_hl_group :CmpItemKindCopilot)
                                            vim_item)
                                       (= entry.source.name :gitcommit)
                                          (do
                                            ; (tset vim_item :kind " SKK")
                                            (tset vim_item :kind " Git")
                                            (tset vim_item :kind_hl_group :CmpItemKindCopilot)
                                            vim_item)
                                        (= entry.source.name :dictionary)
                                        (do
                                          (tset vim_item :kind "﬜ Dict")
                                          (tset vim_item :kind_hl_group :DevIconFsscript)
                                          vim_item)
                                       ((lspkind.cmp_format {:with_text true :maxwidth 50}) entry vim_item)))}
              :mapping (cmp.mapping.preset.insert
                         {
                          :<C-i> (cmp.mapping
                                   (λ [fallback]
                                     (req-f :expand_or_jump_forwards  :cmp_nvim_ultisnips.mappings fallback))
                                   [:i :s])
                          :<C-S-i> (cmp.mapping
                                   (λ [fallback]
                                     (req-f :expand_or_jump_forwards  :cmp_nvim_ultisnips.mappings fallback))
                                   [:i  :s])
                          ; :<tab> (cmp.mapping (λ [fallback]
                          ;                       (if
                          ;                         (cmp.visible)
                          ;                         (cmp.select_next_item)
                          ;                         (let [(line col) (unpack (vim.api.nvim_win_get_cursor 0))]
                          ;                           (and (not= col 0)
                          ;                                (= (-> (vim.api.nvim_buf_get_lines 0 (- line 1) line true)
                          ;                                       (. 1)
                          ;                                       (: :sub col col)
                          ;                                       (: :match :%s))
                          ;                                   nil)))
                          ;                         (cmp.mapping.complete)
                          ;                         (fallback))))
                          :<c-e> (cmp.mapping.abort)
                          :<cr> (cmp.mapping.confirm {:select false}) }) })
           (vim.api.nvim_set_hl 0 :CmpItemKindCopilot {:fg :#6CC644})
           (cmp.setup.cmdline :/ {:mapping (cmp.mapping.preset.cmdline)
                                  :sources [{:name :buffer}]})
           (cmp.setup.cmdline :: {:mapping (cmp.mapping.preset.cmdline)
                                  :sources (cmp.config.sources [{:name :path}] [{:name :cmdline}])}))}

;; highlighting other uses of the current word under the cursor
; {1 :RRethy/vim-illuminate}


{1 :neovim/nvim-lspconfig
 :config (λ []
           (local capabilities ((. (require :cmp_nvim_lsp) :update_capabilities)
                                (vim.lsp.protocol.make_client_capabilities)))
           ; ;; This setting is for kevinhwang91/nvim-ufo {{{
           ; (set capabilities.textDocument.foldingRange {:dynamicRegistration false
           ;                                              :lineFoldingOnly true})
           ; ;; }}}
           (local nvim_lsp (require :lspconfig))
           (each [_ key (ipairs [:rust_analyzer])]
             ((-> nvim_lsp (. key) (. :setup))
              {:capabilities capabilities
               :diagnostics {:enable true

                             :disabled [:unresolved-proc-macro]
                             :enableExperimental true}}))
           ((-> nvim_lsp (. :gopls) (. :setup))
            {:on_attach (lambda [client]
                          (ref-f :on_attach :illuminate client))})

           ; ;; document-color
           ; (set capabilities.textDocument.colorProvider true)
           ; ((-> nvim_lsp (. :tailwindcss) (. :setup))
           ;  {:on_attach (lambda [client]
           ;                (if (client.server_capabilities.colorProvider) 
           ;                  ;; Attach document color support
           ;                  (. (require :document-color) :buf_attach bufnr)))}
           ;  :capabilities capabilities)

           ; (ref-f :setup :ufo)
           ; ((. vim.diagnostic :config) {:virtual_text false})
           )}

{1 :tami5/lspsaga.nvim
 :event [:VimEnter]
 :config (λ [] ((. (require :lspsaga) :setup)
                {:code_action_prompt {:virtual_text false}}))}

;; show type of argument
{1 :ray-x/lsp_signature.nvim
 :config (λ [] ((. (require :lsp_signature) :setup) {}))}

;; tagbar alternative
; :simrat39/symbols-outline.nvim
; {1 :stevearc/aerial.nvim
;  :config (λ []
;            ((req-f :setup :aerial) {:on_attach (λ [bufnr]
;                                                  (let [prefix ((. (require :kaza.map) :prefix-o ) :n :<space>a :aerial)]
;                                                    (prefix.map-buf bufnr :n "t" (cmd :AerialToggle!) :JumpForward)
;                                                    (prefix.map-buf bufnr :n "{" (cmd :AerialPrev) :JumpForward)
;                                                                               (prefix.map-buf bufnr :n "}" (cmd :AerialNext) :JumpBackward)
;                                                    (prefix.map-buf bufnr :n "[[" (cmd :AerialPrevUp) :JumpUpTheTree)
;                                                                                (prefix.map-buf bufnr :n "]]" (cmd :AerialNextUp) :JumpUpTheTree)))}))}
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
                           :heights {:groups {:MyHighlightGroup {:gui :#C792EA
                                                                 :fg :#ff0000
                                                                 :bg :#00ff00}}
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


; ;;; copilot
{1 :zbirenbaum/copilot.lua
 :requires [:github/copilot.vim]
 :event [:VimEnter]
 :config (lambda [] (vim.defer_fn
               (lambda [] ((. (require :copilot) :setup)))
               100))}
{1 :zbirenbaum/copilot-cmp
 :after :copilot.lua
 :config (la (ref-f :setup :copilot_cmp))
 }

{1 :github/copilot.vim
 :config (λ [] (tset vim.g :copilot_no_tab_map true))} ;; requires command `:Copilot restart`

;;; vim
{1 :Shougo/echodoc.vim
 :setup (λ []
          (tset vim.g :echodoc#enable_at_startup true)
          (tset vim.g :echodoc#type :floating))}

;; thank you tpope
{1 :tpope/vim-fugitive
 :cmd [:G :Gdiff]
 :setup (λ []
          (let [ prefix ((. (require :kaza.map) :prefix-o) :n "<space>g" :git)]
            (prefix.map "g" "<cmd>Git<cr>" "add")
            (prefix.map "c" "<cmd>Git commit<cr>" "commit")
            (prefix.map "p" "<cmd>Git push<cr>" "push")))}
:tpope/vim-rhubarb ; enable :Gbrowse
:tpope/vim-commentary
{1 :tpope/vim-unimpaired :event :VimEnter}
:tpope/vim-surround
:tpope/vim-abolish
; {1 :tpope/vim-rsi ; insert mode extension
   ;  :config (la (tset vim.g :rsi_non_meta true))}
:vim-utils/vim-husk
:tpope/vim-repeat
{1 :tpope/vim-sexp-mappings-for-regular-people :after :vim-sexp}
{1 :guns/vim-sexp
 :ft [:fennel]
 :opt true
 :config (λ []
          (tset vim.g :sexp_filetypes "clojure,scheme,lisp,timl,fennel")
          (tset vim.g :sexp_enable_insert_mode_mappings false))}

;;; util
{1 :kana/vim-textobj-user
 :config (λ [] (vim.cmd "source ~/.config/nvim/fnl/core/pack/conf/textobj.vim"))}

{1 :michaeljsmith/vim-indent-object}
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
 :event [:VimEnter]
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

{1 :Cassin01/emacs-key-source.nvim
 :event [:VimEnter]}

;; mark
:kshenoy/vim-signature

:mhinz/neovim-remote

;; Plugin to help me stop repeating the basic movement key.
{1 :takac/vim-hardtime
 :config (la (let-g hardtime_showmsg false)
             (let-g hardtime_default_on false))}

; {1 :notomo/cmdbuf.nvim
;  :config (λ []
;            ;;; FIXME I don't know how to declare User autocmd.
;            (nmaps :q :cmdbuf [[:: (λ [] ((req-f :split_open :cmdbuf) vim.o.cmdwinheight)) "cmdbuf"]
;                               [:l (λ [] ((. (require :cmdbuf) :split_open) vim.o.cmdwinheight {:type :lua/cmd})) "lua"]
;                               [:/ (λ [] ((req-f :split_open :cmdbuf) vim.o.cmdwinheight {:type :vim/search/forward})) :search-forward]
;                               ["?" (λ [] ((. (require :cmdbuf) :split_open) vim.o.cmdwinheight {:type :vim/search/backward})) :search-backward]]))}

;; translation
{1 :skanehira/translate.vim
 :config (λ []
          (tset vim.g :translate_source :en)
          (tset vim.g :translate_target :ja)
          (tset vim.g :translate_popup_window false)
          (tset vim.g :translate_winsize 10)
          (vim.cmd "nnoremap gr <Plug>(Translate)")
          (vim.cmd "vnoremap <c-t> :Translate<cr>"))}

;; zen
:junegunn/limelight.vim
:junegunn/goyo.vim
:amix/vim-zenroom2

;; web browser
{1 :thinca/vim-ref
 :setup (la (vim.cmd "source ~/.config/nvim/fnl/core/pack/conf/vim-ref.vim"))}

;; log
:wakatime/vim-wakatime

:ThePrimeagen/vim-apm

;;; language

;;; deno
:vim-denops/denops.vim
{1 :Cassin01/fetch-info.nvim
 :require :ms-jpq/lua-async-await
 :setup (λ []
          (local a (require :plug.async))
          (local {: u-cmd} (require :kaza))
          (u-cmd :MyGetInfo (la
                              ((. (require :kaza.client) :start) "echo nvim_exec(\'GInfoM\', v:true)"))))}
{1 :ellisonleao/weather.nvim
 :setup (λ [] (tset vim.g :weather_city :Tokyo))}

{1 :vim-skk/skkeleton :requires  [ :vim-denops/denops.vim ]
 :event [:InsertEnter]
:config (λ []
          (let [g (vim.api.nvim_create_augroup :init-skkeleton {:clear true})]
            (au! g :User
                 (vim.fn.skkeleton#config
                   {;:eggLikeNewline false
                    :globalJisyoEncoding :euc-jp
                    :immediatelyJisyoRW true
                    :registerConvertResult false
                    :keepState true
                    :selectCandidateKeys :asdfjkl
                    :setUndoPoint true
                    :showCandidatesCount 4
                    :usePopup true
                    :globalJisyo "~/.config/nvim/data/skk/SKK-JISYO.L"
                    :userJisyo "~/.skkeleton"})
                 {:pattern :skkeleton-initialize-pre})
            (au! g :User (let [cmp (require :cmp)]
                           (cmp.setup.buffer {:view {:entries :native}}))
                 {:pattern :skkeleton-enable-pre})
            (au! g :User (let [cmp (require :cmp)]
                           (cmp.setup.buffer {:view {:entries :custom}}))
                 {:pattern :skkeleton-disable-pre})
            (au! g :User :redrawstatus {:pattern :skkeleton-mode-changed}))
          (map :i :<c-j> (plug "(skkeleton-toggle)") "[skkeleton] toggle")
          (map :c :<c-j> (plug "(skkeleton-toggle)") "[skkeleton] toggle"))}
{1 :Cassin01/cmp-skkeleton :after  [ "nvim-cmp" "skkeleton" ] }
{1 :delphinus/skkeleton_indicator.nvim
 :config (λ [] (ref-f :setup :skkeleton_indicator {}))}

{1 :uki00a/denops-pomodoro.vim}
{1 :skanehira/denops-docker.vim}

;; Async
{1 :ms-jpq/lua-async-await
 :branch :neo}

;; text
{1 :sedm0784/vim-you-autocorrect
 :setup (λ []
          (let [prefix ((. (require :kaza.map) :prefix-o) :n :<space>a :auto-collect)]
            (prefix.map "e" "<cmd>EnableAutocorrect<cr>" "enable auto correct")))}

; ;; tailwind
; {1 :mrshmllow/document-color.nvim
;  :config (λ []
;            ((. (require :document-color) :setup) {:mode :backkground})) }

;; org
; {1 :nvim-orgmode/orgmode ; INFO startup
;  :config (λ []
;            ((. (require :orgmode) :setup) {:org_agenda_files ["~/org/*"]}))}

;; lua
:bfredl/nvim-luadev
{1 :mhartington/formatter.nvim
 :event [:BufWritePre]}

;; binary
:Shougo/vinarise

;; fennel
:bakpakin/fennel.vim  ; syntax
:jaawerth/fennel-nvim ; native fennel support
; :Olical/conjure       ; interactive environment
:Olical/nvim-local-fennel

;; rust
:rust-lang/rust.vim

;; tex
{1 :Cassin01/texrun.vim
 :setup (λ [] (tset vim.g :texrun#file_name [:l02.tex :sample.tex :resume.tex]))}

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
{1 :godlygeek/tabular :opt true :cmd [:Tabularize]}
{1 :preservim/vim-markdown
 :config (λ []
           (tset vim.g :vim_markdown_conceal_code_blocks false))}

{1 :iamcco/markdown-preview.nvim
 :run "cd app & yarn install"
 :config (λ []
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
; :Shougo/unite.vim
; :ujihisa/unite-colorscheme

:folke/tokyonight.nvim
:rebelot/kanagawa.nvim
:sam4llis/nvim-tundra
:Mofiqul/dracula.nvim
:zanglg/nova.nvim


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
; :Mangeshrex/uwu.vim                 ; uwu
; :ulwlu/elly.vim                     ; elly
; :michaeldyrynda/carbon.vim
; :rafamadriz/neon
]
