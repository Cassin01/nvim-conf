(import-macros {: epi : when-let : def} :util.macros)
(import-macros {: au! : la : plug : async-do!} :kaza.macros)
(local {: concat-with} (require :util.list))
(local {: hi-clear : get-hl} (require :kaza.hi))
(local {: syntax} (require :kaza.cmd))
(local vf vim.fn)
(local va vim.api)
(local uv vim.loop)
(local create_autocmd vim.api.nvim_create_autocmd)
(local create_augroup vim.api.nvim_create_augroup)
(local buf_set_option vim.api.nvim_buf_set_option)
(local win_set_option vim.api.nvim_win_set_option)
(local buf_set_keymap vim.api.nvim_buf_set_keymap)
(fn show [msg]
  (vim.api.nvim_echo [[msg]] true {}))

;; remind cursor position
(au! :restore-position :BufReadPost (when (and (> (vim.fn.line "'\"") 1)
                                              (<= (vim.fn.line "'\"") (vim.fn.line "$")))
                                     (vim.cmd "normal! g'\"")))

;;; highlight
;; WARN Should be read before color scheme is loaded.
(when (vim.fn.has :macunix) ; WRAN: this is tempolary
  (au! :hi-default :BufWinEnter (each [_ k (ipairs (require :core.au.hi))]
                                  (vim.api.nvim_set_hl 0 (unpack k)))))

;; annotations
(fn link [name opt]
  (let [data (or (vim.api.nvim_get_hl_by_name name 0) {})]
    (each [k v (pairs opt)]
      (tset data k v))
    data))
(fn blightness [color p]
  (let
    [r (string.sub (vf.printf :%02x (math.floor (* (tonumber (string.sub color 2 3) 16) p))) -2 -1)
     g (string.sub (vf.printf :%02x (math.floor (* (tonumber  (string.sub color 4 5) 16) p))) -2 -1)
     b (string.sub (vf.printf :%02x (math.floor (* (tonumber (string.sub color 6 7) 16) p))) -2 -1)]
    (.. :# r g b)))
; (fn get-hl [name part]
;   "name: hlname
;   part: bg or fg"
;   (let [target (va.nvim_get_hl_by_name name 0)]
;     (if
;       (= part :fg)
;       (.. :# (vf.printf :%0x (or (. target :foreground) 0)))
;       (= part :bg)
;       (.. :# (vf.printf :%0x (or (. target :background) 0)))
;       nil)))

(fn print-second [a b]
  (print (vim.inspect b)))
(au! :match-hi :ColorScheme
     (do
       (vim.api.nvim_set_hl 0 :Comment (link :Comment {:fg (blightness (get-hl :Comment :fg) 1.6)}))
       (each [_ k (ipairs  
                    [;[:Tabs {:bg (blightness (get-hl :Normal :bg) 0.9)}]
                     [:TrailingSpaces {:bg :#FFa331}]
                     [:DoubleSpace {:bg :#cff082}]
                     [:TodoEx {:bg :#44a005 :fg :#F0FFF0}]
                     [:FoldMark (link :Comment {})
                      ; (do
                      ;   (local fg (get-hl :Comment :fg))
                      ;   (if (= nil fg)
                      ;     (link :Comment {})
                      ;     (link :comment (blightness fg 0.8))))
                      ; (link :Comment {:fg (blightness (get-hl :Comment :fg) 0.8)})
                      ]
                     [:CommentHead (link :Comment {:fg :#727ca7})]
                     [:VertSplit (link :LineNr {})]
                     [:StatusLine (link :NonText {})]
                     ; [:StatusLine (link :NonText {:fg (get-hl :StatusLine :fg)})]
                     ; [:BufferLineFill (link :NonText {:fg (get-hl :BufferLineFill :fg)})]
                     ])]
         (vim.api.nvim_set_hl 0 (unpack k)))))
(au! :mmatch [:BufWinEnter] ((. (require :core.au.match) :add-matches)))

;; terminal mode
(au! :term-conf [:TermOpen]
     (do
       (win_set_option 0 :relativenumber false)
       (win_set_option 0 :number false)
       (win_set_option 0 :winfixwidth true)
       ) {:pattern "term://*"})
(au! :term-en [:BufEnter]
     (when (= (. (vim.api.nvim_get_mode) :mode) "nt")
       ; (vim.cmd :startinsert)
       nil)
     {:pattern "term://*"})

;; esc
(au! :esc :BufEnter
     (vim.api.nvim_buf_set_keymap 0 :i "<C-[>" "<ESC>" {:noremap true :silent true :desc "Normal mode"}))

;; vim grep
(create_autocmd
  :QuickFixCmdPost
  {:pattern :*grep*
   :command :cwindow
   :group (create_augroup :grep-cmd {:clear true})})

;; gen directory automatically
(au! :auto-mkdir
     :BufWritePre
     (let [dir (vim.fn.expand :<afile>:p:h)
           force (= vim.v.cmdbang 1)]
       (if (and (= (vim.fn.isdirectory dir) 0)
                (or force (= (vim.fn.confirm (.. dir " does not exist. Create?") "&Yes\n&No") 1)))
         (vim.fn.mkdir dir :p))))

((. (require :lua.winbar) :setup))
(au! :m-winbar :BufWinEnter
     (vim.schedule (lambda []
       ; (local info (vim.fn.getbufinfo (vim.api.nvim_getbuf)))
       ; (local res (not (or
       ;       (= vim.bo.buftype :terminal)
       ;       (= vim.bo.filetype "noice"))))
       ; (print vim.bo.buftype)
       ; (print res)
       (local res (or
                    (= vim.bo.filetype "fennel")
                    (= vim.bo.filetype "lua")
                    (= vim.bo.filetype "rust")
                    (= vim.bo.filetype "tex")
                    (= vim.bo.filetype "python")
                    (= vim.bo.filetype "htmldjango")
                    (= vim.bo.filetype "javascript")
                    (= vim.bo.filetype "go")))
       (when res
         (tset vim.wo :winbar "%{%v:lua.require'lua.winbar'.exec()%}"))))
     {:pattern :*})

;; settings for global status

;; pattern {{{
(fn tex_math []
  (buf_set_keymap 0 :i "$<enter>" "$$$$<left><cr><cr><up>" {:noremap true})
  (buf_set_keymap 0 :i "$$" "$$<left>" {:noremap true :nowait true}))

(create_autocmd
  :ColorScheme
  {:callback (λ []
               (if (= vim.o.laststatus 3)
                 (hi-clear :VerSplit)))
   :group (create_augroup :global-status {:clear true})})

(local pattern (create_augroup :pattern {:clear true}))
(create_autocmd
  [:BufRead :BufNewFile]
  {:callback (λ []
               (buf_set_option 0 :commentstring "// %s")
               (win_set_option 0 :foldmethod :indent)
               (buf_set_keymap 0
                               :i
                               :/*
                               :<kDivide><kMultiply><space><space><kMultiply><kDivide><left><left><left>
                               {:noremap true}))
   :pattern [:*.c :*.h :*.cpp :*.rs :*.go]
   :group pattern})
(create_autocmd
  [:BufRead :BufNewFile]
  {:callback (λ []
              (win_set_option 0 :foldmethod :indent))
   :pattern [:*.py]
   :group pattern})
(create_autocmd
  [:BufRead :BufNewFile]
  {:callback (λ []
              (win_set_option 0 :foldmethod :marker)
              (buf_set_keymap 0 :i "\"" "\"" {:noremap true}))
   :pattern [:*.vim]
   :group pattern})
(create_autocmd
  [:BufRead :BufNewFile]
  {:callback (λ []
               (tset vim.g :tex_conceal "")
               (tex_math)
               (buf_set_keymap 0 :i "<C-l>" "$$<left>" {:noremap true :nowait true})
               (local indent 2)
               (tset vim.bo :tabstop indent)
               (tset vim.bo :shiftwidth indent)
               (tset vim.bo :softtabstop indent)
               (vim.cmd "setlocal iskeyword+=\\")
               (if (. vim.g :vim-auto-save)
                 (tset vim.g :auto_save 1)))
   :pattern [:*.tex]
   :group pattern})

(vim.fn.setcellwidths
  [[0x9789 0x9789 2]
   [0x978B 0x978B 2]])

(fn todo []
  ;; https://gist.github.com/huytd/668fc018b019fbc49fa1c09101363397
  (vf.matchadd :Conceal "\\(^\\s*\\)\\@<=- \\[\\s\\]" 1 -1 {:conceal :})
  (vf.matchadd :Conceal "\\(^\\s*\\)\\@<=- \\[x\\]" 1 -1 {:conceal :})
  ; (vf.matchadd :Comment "^---" 1 -1 {:conceal "• "})
  (vf.matchadd :Conceal "\\(^\\s*\\)\\@<=-\\(\\s\\)\\@=" 0 -1 {:conceal "• "})
  (vf.matchadd :Conceal "^#\\(\\s\\)\\@=" 0 -1 {:conceal "◉"})
  (vf.matchadd :Conceal "^##\\(\\s\\)\\@=" 0 -1 {:conceal "○" })
  (vf.matchadd :Conceal "^###\\(\\s\\)\\@=" 0 -1 {:conceal "✹" })
  ; (syntax "syntax match todoCheckbox \\\'\\v(\\s+)?(-|\\*)\\s\\[-\\]\\\'hs=e-4 conceal cchar=☒")
  ; (syntax "syntax match todoCheckbox \'\\\[x\\\]\' conceal cchar=☒")
  (vim.cmd "hi def link todoCheckbox Todo")
  (vim.cmd "setlocal cole=1")
  (vim.cmd "setlocal comments=nb:>,b:-\\ [\\ ],b:-\\ [x],b:-")
  (local indent 2)
  (vim.cmd "setlocal formatoptions-=c formatoptions+=jro")
  (vim.cmd (string.format "setlocal shiftwidth=%d" 2))
  (vim.cmd (string.format "setlocal tabstop=%d" 2))
  (vim.cmd (string.format "setlocal softtabstop=%d" 2))
  (buf_set_keymap 0 :n "<localleader>td" "a- [ ] " {:noremap true :desc "markdown add checkbox"}))
(create_autocmd
  [:BufRead :BufNewFile]
  {:callback (λ []
               (todo))
   :pattern [:*.txt]
   :group pattern})
(create_autocmd
  [:BufRead :BufNewFile]
  {:callback (λ []
               (todo))
   :pattern [:*.org]
   :group pattern})
(create_autocmd
  [:BufRead :BufNewFile]
  {:callback (λ []
               (win_set_option 0 :foldenable false)
               (tex_math)
               (todo))
   :pattern [:*.md]
   :group pattern})
(create_autocmd
  [:BufRead :BufNewFile]
  {:callback (λ []
               (buf_set_option 0 :shiftwidth 2)
               (vim.cmd "setlocal iskeyword-=_")
               (vim.cmd "setlocal iskeyword-=-"))
   :pattern [:*.lisp :*.fnl]
   :group pattern})
(create_autocmd
  [:BufRead :BufNewFile]
  {:callback (λ []
               (buf_set_option 0 :shiftwidth 2)
               (vim.cmd "setlocal iskeyword-=_")
               (vim.cmd "setlocal iskeyword-=-")
               (local fullpath (vim.fn.expand "%:p"))
               (vim.keymap.set "n" "<Space>rs"
                               (.. "<cmd>!scheme --quiet < " fullpath "<cr>")
                               {:silent true :buffer 0})
               )
   :pattern [:*.scm]
   :group pattern})

;; }}}
(when (vim.fn.has :mac)
  (au! :adoc_preview :BufWritePost
       (let [cmd (concat-with
                   " "
                   "(cd"
                   (vf.expand :%:h)
                   :&&
                   "asciidoctor --backend html5"
                   (.. (vf.expand :%:r) :.adoc)
                   "-o"
                   (vf.expand "~/.cache/nvim/adoc_preview/index.html")
                   ")")]
        (local job (vim.fn.jobstart [:zsh :-c cmd])))
    {:pattern :*.adoc})
  (local {: u-cmd} (require :kaza))
  (u-cmd :AdocPreview
         (lambda []
           (when (not vim.g.adoc_preview)
             (tset vim.g :adoc_preview true)
             (let [cmd1 (concat-with
                         " "
                         :livereloadx
                         :-s
                         :-p
                         :9000
                         (vf.expand "~/.cache/nvim/adoc_preview/"))
                   cmd2 (concat-with " " :open "http://localhost:9000")]
               (local job1 (vim.fn.jobstart [:zsh :-c cmd1]))
               (local job2 (vim.fn.jobstart [:zsh :-c cmd2])))))))

;;; plugin specific

;; sche
; (local sche (require :core.au.sche))
; (sche.setup {:sche_path (vim.fn.expand "~/.config/nvim/data/10.sche")
;              :syntax {:month "'^\\(\\d\\|\\d\\d\\)月'"}})

;; packer
; (create_autocmd
;   :BufWritePost
;   {:command :PackerCompile
;    :pattern :plugs.fnl
;    :group (create_augroup :packer-compile {:clear true})})

;; ref-view
(au! :ref-view
    :FileType
    (let [{: bmap} (require :kaza.map)]
      (epi _ k [[:n :b (plug "(ref-back)") :back]
                [:n :f (plug "(ref-forward)") :forward]
                [:n :q :<c-w>c :quit]]
           (bmap 0 (unpack k))))
    {:pattern :ref})

; ;; copilot
; (au! :reload-copilot
;      :VimEnter
;      (vim.cmd "Copilot restart"))


;; bufferline
(au! :reload-devicon
     ; [:BufWinEnter :BufWinLeave :BufReadPost]
     ; [:BufWinEnter :TabEnter :WinEnter]
     [:BufEnter :BufLeave :WinEnter :WinLeave :TabEnter :TabLeave :BufWinEnter :BufWinLeave :BufReadPost :BufReadPre]
     (do
       (when-let fg (get-hl :Comment :fg)
                 (local cs (vim.api.nvim_get_hl 0 {}))
                 (each [hi-name _ (pairs cs)]
                   (when (not= (hi-name:match "^BufferLineDevIcon.*Inactive$") nil)
                     (vim.cmd (.. "hi " hi-name " guifg=" fg))))))
     {})
