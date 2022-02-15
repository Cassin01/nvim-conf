
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
(local state {:# 1})
(global lime {})

(fn idx []
  "return a ordered, commandmode-safe id"
  (let [id state.#]
    (set state.# (+ id 1))
    (.. "_" id)))

(fn bind [data]
  "bind a data table and return its vlua"
  (let [idx (idx)]
    (if (= (type data.rhs) :function)
      (let [vlua (.. "v:lua.lime." idx ".fn")
            vlua (match data
                   {:kind "keymap" :opt {:expr true}}
                   (.. vlua "()")
                   {:kind "keymap"}
                   (.. ":call " vlua "()<cr>")
                   {:kind "autocmd"}
                   (.. ":call " vlua "()")
                   {:kind "user"}
                   vlua)]
        (set data.fn data.rhs)
        (set data.rhs vlua)
        (tset lime idx data)
        data)
      (do
        (tset lime idx data)
        data))))

(fn concat [xs d]
  (let [d (or d "")]
    (if (= (type xs) :table)
      (table.concat xs d)
      xs)))

; let
(macro let-g [k v]
  "set 'k' to 'v' on vim.g table"
  `(tset vim.g ,(tostring k) ,v))

;  set
; (macro se- [k v]
;   (if (= (type v) "boolean")
;         `(vim.api.nvim_set_option ,(tostring k) ,v) `(set ,(sym (.. "vim.o." (tostring k))) ,v) ))
(macro se- [k v]
  `(set ,(sym (.. "vim.o." (tostring k))) ,v))
 
; auto
(fn auc [eve pat rhs]
  (let [data (bind {:kind "autocmd" : eve : pat : rhs})]
    (vim.cmd (.. "autocmd "
                 (concat data.eve ",") " "
                 (concat data.pat ",") " "
                 data.rhs " "))))

(fn aug [name f]
  (vim.cmd (concat ["augroup " name] " "))
  (vim.cmd "autocmd!") ; TODO dirty stuff
  (vim.cmd f)
  (vim.cmd "augroup END"))
;; }}}

(local fennel (require :fennel))
; (import-macros {: se-m} :conf.macros)

(print (vim.fn.expand "%:p"))

(let-g python2_host_prog "/usr/local/bin/python")
(let-g python3_host_prog "/Users/cassin/.pyenv/shims/python")
(se- fenc "utf-8")
(se- backup false)
(se- swapfile false)
(se- autoread true)
(se- tabstop 4)
(se- shiftwidth 4)
(se- expandtab true)
(se- number true)
(se- scrolloff 10)
(se- cursorline true)
(se- incsearch true)
(se- termguicolors true)
(se- list true)
(se- listchars "tab:»-,trail:□")
(se- spell true)
(se- spelllang "en,cjk")
(se- ignorecase true)
(vim.cmd "hi clear SpellBad")
(vim.cmd "set mouse=a")
(vim.cmd "lang en_US.UTf-8")
(vim.cmd "filetype plugin indent on")
(let-g my_color "purify")
(vim.cmd "set t_8f=^[[38;2;%lu;%lu;%lum")
(vim.cmd "set t_8b=^[[48;2;%lu;%lu;%lum")
(let [cmd (auc ["BufRead"] ["*"] "if line(\"'\\\"\") > 0 && line(\"'\\\"\") <= line(\"$\") | exe \"normal g`\\\"\" | endif")]
(aug "vimrcEx" cmd))
