(local M {})

;;; replace fennel string to lua string
;;; \a: Bell
;;; \b: Backspace
;;; \f: Form feed
;;; \n: Newline
;;; \r: Carriage return
;;; \t: Tab
;;; \v: Vertical tab
;;; \\: Backslash
;;; \": Double quote
;;; \': Single quote
;;; \nnn: Octal value (nnn is 3 octal digits)
;;; \xNN: Hex value (Lua5.2/LuaJIT, NN is two hex digits)

(fn M.gen-lua-string [s]
  (let [l (string.gsub s "\\" "\\\\")
        l (string.gsub l "\"" "\\\"")
        ] l))

(fn M.def-aucmd [eve pat rhs]
  (.. "autocmd "
      (table.concat eve ",") " "
      (table.concat pat ",") " "
      rhs " "))

; (local v 0)
;
; (fn thrice-if [body dict]
;   (fn step [i]
;     `(do ,body ,(step (- i 1))))
;   (step (length dict)))
;
; ;;; idont know how to count this ...
; (fn set-key [i dict]
;       (tset new_dict (.. (tostring count) ": " k) (. dict i)))
;
; (fn M.gen-hash-key-for-dict [dict]
;   (thrice-if set-key dict))

M
