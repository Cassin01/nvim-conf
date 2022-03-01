;;; nivm/embedded.fnl

(import-macros m :util.src.macros)

(fn _encode [s]
  "convert characters of string 's' to byte_"
  (if (= (type s) :string)
    `,(.. "_" (string.gsub s "." (fn [KAZA_C#] (.. (string.byte KAZA_C#) "_"))))
    `(.. "_" (string.gsub ,s "." (fn [KAZA_C#] (.. (string.byte KAZA_C#) "_"))))))

(fn _vlua [f kind id]
  "store function 'f' into _G._KAZA and return its v:lua"
  (if id
    `(let [KAZA_ID# ,(_encode id)]
       (tset _G._KAZA ,kind KAZA_ID# ,f)
       (.. ,(.. "v:lua._KAZA." kind ".") KAZA_ID#))
    `(let [KAZA_N# (. _G._KAZA ,kind :#)
           KAZA_ID# (.. "_" KAZA_N#)]
       (tset _G._KAZA ,kind KAZA_ID# ,f)
       (tset _G._KAZA ,kind :# (+ KAZA_N# 1))
       (.. ,(.. "v:lua._KAZA." kind ".") KAZA_ID#))))

(fn set-option [k v]
  `(set ,(sym (.. "vim.o." (tostring k))) ,v))

(fn let-global [k v]
  "set 'k' to 'v' on vim.g table"
  `(tset vim.g ,(tostring k) ,v))

;; ref: https://github.com/shaunsingh/nyoom.nvim/blob/main/fnl/conf/macros.fnl
(fn cmd [string]
  "execute vim command"
  `(vim.cmd ,string))

;(fn augroup* [group body]
;  "same as augroup, but body is macro"
;  (let [{: cmd} vim
;        clear true]
;    (cmd (.. "augroup " group))
;    (when clear
;      (cmd :au!))
;    (body)
;    (cmd "augroup END")))

;(fn augroup* [group body]
;  "same as augroup, but body is macro"
;  (let [ clear true]
;    `(do
;       (vim.cmd (.. "augroup " group))
;       ,(when clear
;         `(vim.cmd :au!))
;       ,body
;       (vim.cmd "augroup END"))))
;
;
;(fn autocmd* [group pattern body]
;  ;(local cmdheader (.. group " " pattern " " :Fnl " "))
;  `(let [group# ,group
;         pattern# ,pattern
;         body# ,body]
;    (vim.cmd ,(.. :autocmd " " ,group " " ,pattern " " :call " " "_G.hoge" " " "()")
;             )))
;
;; ref: https://notabug.org/dm9pZCAq/dotfiles/src/master/.config/nvim/fnl/utils/vim.fnl

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
 : cmd
 }
