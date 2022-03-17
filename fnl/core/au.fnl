(local create_autocmd vim.api.nvim_create_autocmd)
(local create_augroup vim.api.nvim_create_augroup)

(local restore-position (create_augroup :restore-position {:clear true}))
(create_autocmd
  :BufReadPost
  {:callback (lambda []
               (when (and (> (vim.fn.line "'\"") 1)
                          (<= (vim.fn.line "'\"") (vim.fn.line "$")))
                 (vim.cmd "normal! g'\"")))
   :group restore-position})
