(local {: hi-clear} (require :kaza.hi))
(local create_autocmd vim.api.nvim_create_autocmd)
(local create_augroup vim.api.nvim_create_augroup)

;; packer
(local packer-compile (create_augroup :packer-compile {:clear true}))
(create_autocmd
  :BufWritePost
  {:command :PackerCompile
   :pattern :plugs.fnl
   :group packer-compile})

;; remind cursor position
(local restore-position (create_augroup :restore-position {:clear true}))
(create_autocmd
  :BufReadPost
  {:callback (λ []
               (when (and (> (vim.fn.line "'\"") 1)
                          (<= (vim.fn.line "'\"") (vim.fn.line "$")))
                 (vim.cmd "normal! g'\"")))
   :group restore-position})

; highlight
(local hi (create_augroup :hi {:clear true}))
(create_autocmd
  :ColorScheme
  {:callback (λ []
               (vim.api.nvim_set_hl 0 :NonText {:fg :#0d0000
                                               :bg nil
                                               :underline true})
               (each [_ k (ipairs (require :core.au.hi))]
                 (vim.api.nvim_set_hl 0 (unpack k))))})


;; disable coc at first
(local coc-disable (create_augroup :coc-disable {:clear true}))
(create_autocmd
  :BufReadPost
  {:command :CocDisable
   :group coc-disable})

;; settings for global status
(local global-status (create_augroup :global-status {:clear true}))
(create_autocmd
  :ColorScheme
  {:callback (λ []
               (if (= vim.o.laststatus 3)
                 (hi-clear :VerSplit)))
   :group :global-status})
