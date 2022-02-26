(fn set-option [k v]
  `(set ,(sym (.. "vim.o." (tostring k))) ,v))

(fn let-global [k v]
  "set 'k' to 'v' on vim.g table"
  `(tset vim.g ,(tostring k) ,v))

; (fn concat [xs d]
;   (let [d (or d "")]
;     (if (= (type xs) :table)
;       (table.concat xs d)
;      xs)))

;(fn def-aucmd [eve pat rhs]
;   (vim.cmd (.. "autocmd "
;       (table.concat eve ",") " "
;       (table.concat pat ",") " "
;       rhs " ")))
;
;(fn def-autogroup [name cmd]
;  (print (type cmd))
;  `((vim.cmd (,table.concat ["augroup " name] " "))
;  (vim.cmd "autocmd!") ; TODO dirty stuff
;  (cmd)
;  (vim.cmd "augroup END")))


; ;;; MARK not actually 'embedded' functio
; (fn thrice-if [body dict]
;   (fn step [i]
;     `(do ,body ,(step (- i 1))))
;   (step (length dict)))
;
; ;;; idont know how to count this ...
; (fn set-key [i dict]
;       (tset new_dict (.. (tostring count) ": " k) (. dict i)))
;
; (gen-hash-key-for-dict [dict]
;  (thrice-if set-key dict))

{: set-option
 : let-global
 }
