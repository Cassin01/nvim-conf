;; ref: https://github.com/tsbohc/zest.nvim/blob/master/fnl/zest/macros.fnl
; 
; (macro M.se-2 [k v]
;   (if (= (type v) "boolean")
;         `(vim.api.nvim_set_option ,(tostring k) ,v) `(set ,(sym (.. "vim.o." (tostring k))) ,v) ))

(macro seg [k v]
  `(set ,(sym (.. "vim.o." (tostring k))) ,v))

(fn hoge []
  (print "hoge"))

{:sem hoge}
