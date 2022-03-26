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
  :ColorScheme
  {:callback (λ []
               (vim.api.nvim_set_hl 0 :NonText {:fg :#0d0000
                                                :bg nil
                                                :underline true})
               (each [_ k (ipairs (require :core.au.hi))]
                 (vim.api.nvim_set_hl 0 (unpack k))))
   :group (create_augroup :hi {:clear true})})

; terminal mode
(create_autocmd
  :TermOpen
  {:callback (λ [] (win_set_option 0 :relativenumber false))
   :group (create_augroup :term-conf {:clear true})})

;; settings for global status

;; pattern {{{
(fn tex_math []
  (buf_set_keymap 0 "$<enter>" "$$$$<left><cr><cr><up>" {:noremap true})
  (buf_set_keymap 0 "$$" "$$<left>" {:noremap true}))

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
               (buf_set_option 0 :foldmethod :indent)
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
              (buf_set_option 0 :foldmethod :indent))
   :pattern [:*.py]
   :group pattern})
(create_autocmd
  [:BufRead :BufNewFile]
  {:callback (λ []
              (buf_set_option 0 :foldmethod :marker)
              (buf_set_keymap 0 :i "\"" "\"" {:noremap true}))
   :pattern [:*.vim]
   :group pattern})
(create_autocmd
  [:BufRead :BufNewFile]
  {:callback (λ []
               (tset vim.g :tex_conceal "")
               (tex_math)
               (if (vim.fn.has_key vim.g :vim-auto-save)
                 (tset vim.g :auto_save 1)))
   :pattern [:*.tex]
   :group pattern})
(create_autocmd
  [:BufRead :BufNewFile]
  {:callback (λ []
               (buf_set_option 0 :foldenable false)
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

;; disable coc at first
(create_autocmd
  :BufReadPost
  {:command :CocDisable
   :group (create_augroup :coc-disable {:clear true})})
