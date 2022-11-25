(import-macros {: epi} :util.macros)
(import-macros {: au! : la : plug : async-do!} :kaza.macros)
(local {: concat-with} (require :util.list))
(local {: hi-clear} (require :kaza.hi))
(local {: syntax} (require :kaza.cmd))
(local vf vim.fn)
(local va vim.api)
(local uv vim.loop)
(local create_autocmd vim.api.nvim_create_autocmd)
(local create_augroup vim.api.nvim_create_augroup)
(local buf_set_option vim.api.nvim_buf_set_option)
(local win_set_option vim.api.nvim_win_set_option)
(local buf_set_keymap vim.api.nvim_buf_set_keymap)

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
  (let [data (vim.api.nvim_get_hl_by_name name 0)]
    (each [k v (pairs opt)]
      (tset data k v))
    data))
(fn blightness [color p]
  (let
    [r (string.sub (vf.printf :%0x (math.floor (* (tonumber (string.sub color 2 3) 16) p))) -2 -1)
     g (string.sub (vf.printf :%0x (math.floor (* (tonumber  (string.sub color 4 5) 16) p))) -2 -1)
     b (string.sub (vf.printf :%0x (math.floor (* (tonumber (string.sub color 6 7) 16) p))) -2 -1)]
    (.. :# r g b)))
(fn get-hl [name part]
  "name: hlname
  part: bg or fg"
  (let [target (va.nvim_get_hl_by_name name 0)]
    (if
      (= part :fg)
      (.. :# (vf.printf :%0x (. target :foreground)))
      (= part :bg)
      (.. :# (vf.printf :%0x (. target :background)))
      nil)))

(fn print-second [a b]
  (print (vim.inspect b)))
(au! :match-hi :ColorScheme 
     (each [_ k (ipairs [;[:Tabs {:bg (blightness (get-hl :Normal :bg) 0.9)}]
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
                         [:VertSplit (link :NonText {})]
                         [:StatusLine (link :NonText {})]
                         ; [:StatusLine (link :NonText {:fg (get-hl :StatusLine :fg)})]
                         ; [:BufferLineFill (link :NonText {:fg (get-hl :BufferLineFill :fg)})]
                         ])]
       (vim.api.nvim_set_hl 0 (unpack k))))
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

;; vim grep
(create_autocmd
  :QuickFixCmdPost
  {:pattern :*grep*
   :command :cwindow
   :group (create_augroup :grep-cmd {:clear true})})

;; settings for global status

;; pattern {{{
(fn tex_math []
  (buf_set_keymap 0 :i "$<enter>" "$$$$<left><cr><cr><up>" {:noremap true})
  (buf_set_keymap 0 :i "$$" "$$<left>" {:noremap true}))

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
   :pattern [:*.c :*.h :*.cpp :*.rs]
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
               (local indent 2)
               (tset vim.bo :tabstop indent)
               (tset vim.bo :shiftwidth indent)
               (tset vim.bo :softtabstop indent)
               (vim.cmd "setlocal iskeyword+=\\")
               (if (. vim.g :vim-auto-save)
                 (tset vim.g :auto_save 1)))
   :pattern [:*.tex]
   :group pattern})
(fn todo []
  ;; https://gist.github.com/huytd/668fc018b019fbc49fa1c09101363397
  (vf.matchadd :Conceal "^\\s*- \\[\\s\\]" 1 -1 {:conceal :})
  (vf.matchadd :Conceal "^\\s*- \\[x\\]" 1 -1 {:conceal :})
  (vf.matchadd :Comment "^---" 1 -1 {:conceal "• "})
  (vf.matchadd :Conceal "^\\s*-" 0 -1 {:conceal "• "})
  (vf.matchadd :Conceal "^#" 0 -1 {:conceal "◉"})
  (vf.matchadd :Conceal "^##" 0 -1 {:conceal "○" })
  (vf.matchadd :Conceal "^###" 0 -1 {:conceal "✹" })
  ; (syntax "syntax match todoCheckbox \\\'\\v(\\s+)?(-|\\*)\\s\\[-\\]\\\'hs=e-4 conceal cchar=☒")
  ; (syntax "syntax match todoCheckbox \'\\\[x\\\]\' conceal cchar=☒")
  (vim.cmd "hi def link todoCheckbox Todo")
  (vim.cmd "setlocal cole=1"))
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

;; }}}
(when (vim.fn.has :mac)
  (au! :adoc_preview :BufWritePost
       (let [cmd (concat-with " " "(cd"
                     (vf.expand :%:h)
                     :&&
                     "asciidoctor --backend html5"
                     (.. (vf.expand :%:r) :.adoc)
                     "-o"
                     (vf.expand "~/.cache/nvim/adoc_preview/index.html")
                     ; (.. (vf.expand :%:r) :.html)
                     ")")]
        (async-do! (vim.cmd (.. :! cmd))))
    {:pattern :*.adoc})
  (local {: u-cmd} (require :kaza))
  (u-cmd :AdocPreview
         (la
           (let [cmd (concat-with " "
                                  :livereloadx
                                  :-s
                                  :-p
                                  :9000
                                  (vf.expand "~/.cache/nvim/adoc_preview/")
                                  )
                 cmd_open (concat-with " " :open "http://localhost:9000")
                 ]
              ; (async-do! (vim.cmd (.. :! cmd)))
              (local job (vim.fn.jobstart [:zsh :-c cmd]))
              (async-do! (vim.cmd (.. :! cmd_open)))
              ))))

;;; plugin specific

;; sche
; (local sche (require :core.au.sche))
; (sche.setup {:sche_path (vim.fn.expand "~/.config/nvim/data/10.sche")
;              :syntax {:month "'^\\(\\d\\|\\d\\d\\)月'"}})

;; packer
(create_autocmd
  :BufWritePost
  {:command :PackerCompile
   :pattern :plugs.fnl
   :group (create_augroup :packer-compile {:clear true})})

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
