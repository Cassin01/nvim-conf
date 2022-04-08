(local {: hi-clear} (require :kaza.hi))
(local create_autocmd vim.api.nvim_create_autocmd)
(local create_augroup vim.api.nvim_create_augroup)
(local buf_set_option vim.api.nvim_buf_set_option)
(local win_set_option vim.api.nvim_win_set_option)
(local buf_set_keymap vim.api.nvim_buf_set_keymap)

(macro au [group event body]
  `(vim.api.nvim_create_autocmd ,event {:callback (λ [] ,body) :group (vim.api.nvim_create_augroup ,group {:clear true})}))

;; remind cursor position
(au :restore-position :BufReadPost (when (and (> (vim.fn.line "'\"") 1)
                                              (<= (vim.fn.line "'\"") (vim.fn.line "$")))
                                     (vim.cmd "normal! g'\"")))

;;; highlight

(au :hi-default :BufWinEnter (each [_ k (ipairs (require :core.au.hi))]
                       (vim.api.nvim_set_hl 0 (unpack k))))

;; anotations
(au :match-hi :ColorScheme (each [_ k (ipairs [[:Tabs {:bg :#eeaecc}]
                                               [:TrailingSpaces {:bg :#FFa331}]
                                               [:DoubleSpace {:bg :#cff082}]
                                               [:TodoEx {:bg :#44a005 :fg :#F0FFF0}]])]
                             (vim.api.nvim_set_hl 0 (unpack k))))
(au :match [:BufWinEnter] (. (require :core.au.match) :add-matchs))

; terminal mode
(au :term-conf :TermOpen (do
                           (win_set_option 0 :relativenumber false)
                           (win_set_option 0 :number false)))
; vim grep
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
               (if (. vim.g :vim-auto-save)
                 (tset vim.g :auto_save 1)))
   :pattern [:*.tex]
   :group pattern})
(create_autocmd
  [:BufRead :BufNewFile]
  {:callback (λ []
               (win_set_option 0 :foldenable false)
               (tex_math))
   :pattern [:*.md]
   :group pattern})
(create_autocmd
  [:BufRead :BufNewFile]
  {:callback (λ []
               (buf_set_option :shiftwidth 2))
   :pattern [:*.lisp]
   :group pattern})
;; }}}

;;; plugin specific

;; packer
(create_autocmd
  :BufWritePost
  {:command :PackerCompile
   :pattern :plugs.fnl
   :group (create_augroup :packer-compile {:clear true})})
