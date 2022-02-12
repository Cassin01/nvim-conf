
;;  ██╗███╗   ██╗██╗████████╗███████╗███╗   ██╗██╗
;;  ██║████╗  ██║██║╚══██╔══╝██╔════╝████╗  ██║██║
;;  ██║██╔██╗ ██║██║   ██║   █████╗  ██╔██╗ ██║██║
;;  ██║██║╚██╗██║██║   ██║   ██╔══╝  ██║╚██╗██║██║
;;  ██║██║ ╚████║██║   ██║██╗██║     ██║ ╚████║███████╗
;;  ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝╚═╝╚═╝     ╚═╝  ╚═══╝╚══════╝
;;
;;                 presented by
;;
;;               ╔═╗┌─┐┌─┐┌─┐┬┌┐┌
;;               ║  ├─┤└─┐└─┐││││
;;               ╚═╝┴ ┴└─┘└─┘┴┘└┘

;; Macros {{{
(local M {})

(macro M.let-g [k v]
  "set 'k' to 'v' on vim.g table"
  `(tset vim.g ,(tostring k) ,v))

(macro se- [k v]
  (if (= (type v) "boolean")
        `(vim.api.nvim_set_option ,(tostring k) ,v) `(set ,(sym (.. "vim.o." (tostring k))) ,v) ))
;; }}}

(se- fenc "utf-8")
(se- tabstop 4)
(se- shiftwidth 4)
(se- scrolloff 10)
(se- expandtab true)
(se- backup false)
(se- autoread true)
(se- number true)
(se- cursorline true)
(vim.cmd "set mouse=a")
(se- incsearch true)
(vim.cmd "lang en_US.UTf-8")

(set _G.my_color "purify")
