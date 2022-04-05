(local {: hi-clear} (require :kaza.hi))
(local create_autocmd vim.api.nvim_create_autocmd)
(local create_augroup vim.api.nvim_create_augroup)
(local buf_set_option vim.api.nvim_buf_set_option)
(local win_set_option vim.api.nvim_win_set_option)
(local buf_set_keymap vim.api.nvim_buf_set_keymap)

;; remind cursor position
(create_autocmd
  :BufReadPost
  {:callback (λ []
               (when (and (> (vim.fn.line "'\"") 1)
                          (<= (vim.fn.line "'\"") (vim.fn.line "$")))
                 (vim.cmd "normal! g'\"")))
   :group (create_augroup :restore-position {:clear true})})

; highlight
(create_autocmd
  :InsertEnter
  {:callback (λ []
               (each [_ k (ipairs (require :core.au.hi))]
                 (vim.api.nvim_set_hl 0 (unpack k))))
   :group (create_augroup :hi-match {:clear true})})

(create_autocmd
  :InsertEnter
  {:callback (λ []
               (each [_ k (ipairs [[:Tabs {:bg :#eeeeec}]
                                   [:TrailingSpaces {:bg :#FF0000}]
                                   [:DoubleSpace {:bg :#FF0682}]
                                   [:TodoEx {:bg :#44a005 :fg :#FFFFF0}]])]
                 (vim.api.nvim_set_hl 0 (unpack k))))
   :group (create_augroup :hi {:clear true})})
(create_autocmd
  [:ColorScheme :BufRead :BufNew]
  {:callback (. (require :core.au.match) :add-matchs)
   :group (create_augroup :add-matchs {:clear true})})

; terminal mode
(create_autocmd
  :TermOpen
  {:callback (λ []
               (win_set_option 0 :relativenumber false)
               (win_set_option 0 :number false))
   :group (create_augroup :term-conf {:clear true})})

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
