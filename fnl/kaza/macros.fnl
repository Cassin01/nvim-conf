(local M {})

(fn M.set-option [k v]
  `(set ,(sym (.. "vim.o." (tostring k))) ,v))

(fn M.let-global [k v]
  "set 'k' to 'v' on vim.g table"
  `(tset vim.g ,(tostring k) ,v))

(fn M.use+ [plug]
  `(if (not (-?> pack (. :disable)))
     (use ,plug)))

M
