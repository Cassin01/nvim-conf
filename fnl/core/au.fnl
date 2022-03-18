(local create_autocmd vim.api.nvim_create_autocmd)
(local create_augroup vim.api.nvim_create_augroup)

(local packer-compile (create_augroup :packer-compile {:clear true}))
(create_autocmd
  :BufWritePost
  {:command :PackerCompile
   :pattern :plugs.fnl
   :group packer-compile})

(local restore-position (create_augroup :restore-position {:clear true}))
(create_autocmd
  :BufReadPost
  {:callback (λ []
               (when (and (> (vim.fn.line "'\"") 1)
                          (<= (vim.fn.line "'\"") (vim.fn.line "$")))
                 (vim.cmd "normal! g'\"")))
   :group restore-position})

(local coc-disable (create_augroup :coc-disable {:clear true}))
(create_autocmd
  :BufReadPost
  {:command :CocDisable
   :group coc-disable})
