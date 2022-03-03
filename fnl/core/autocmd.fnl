(import-macros
  {: def-augroup
   : def-autocmd-fn} :kaza.macros)

(def-augroup :restore-position
  (def-autocmd-fn :BufReadPost "*"
    (when (and (> (vim.fn.line "'\"") 1)
               (<= (vim.fn.line "'\"") (vim.fn.line "$")))
      (vim.cmd "normal! g'\""))))
