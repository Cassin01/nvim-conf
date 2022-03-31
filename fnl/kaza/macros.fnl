(local M {})

(fn M.set-option [k v]
  `(set ,(sym (.. "vim.o." (tostring k))) ,v))

(fn M.let-global [k v]
  "set 'k' to 'v' on vim.g table"
  `(tset vim.g ,(tostring k) ,v))

(fn M.pack+ [name opt]
  "add disable option to packer"
  (when (not (-?> opt (. :disable)))
    (tset opt 1 name)
    opt))


M
