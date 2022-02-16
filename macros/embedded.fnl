(fn set-option [k v]
  `(set ,(sym (.. "vim.o." (tostring k))) ,v))

(fn test []
  `(print "macros called!"))

(fn let-global [k v]
  "set 'k' to 'v' on vim.g table"
  `(tset vim.g ,(tostring k) ,v))

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

(fn def-aucmd [eve pat rhs]
  (let [data (bind {:kind "autocmd" : eve : pat : rhs})]
    (vim.cmd (.. "autocmd "
                 (concat data.eve ",") " "
                 (concat data.pat ",") " "
                 data.rhs " "))))

(fn def-autogroup [name f]
  (vim.cmd (concat ["augroup " name] " "))
  (vim.cmd "autocmd!") ; TODO dirty stuff
  (vim.cmd "echo \"hoge\"")
  (vim.cmd "augroup END"))

{: set-option
 : let-global
 : test
 : def-aucmd
 : def-autogroup}
