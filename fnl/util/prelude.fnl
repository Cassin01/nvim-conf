;;;; Reference:
;;;; https://tomitomix.hatenablog.com/entry/2017/12/06/184950
;;;; https://github.com/andreyorst/fennel-cljlib/blob/master/init-macros.fnl

;;; type
;;; * list - return a list, which is a special kind of table used for code.
;;; * sym - turn a string into a symbol.
;;; * gensym - generates a unique symbol for use in macros, accepts an optional prefix string.
;;; * list? - is the argument a list? Returns the argument or false.
;;; * sym? - is the argument a symbol? Returns the argument or false.
;;; * table? - is the argument a non-list table? Returns the argument or false.
;;; * sequence? - is the argument a non-list sequential table (created with [], as opposed to {})? Returns the argument or false.
;;; * varg? - is this a ... symbol which indicates var args? Returns a special table describing the type or false.
;;; * multi-sym? - a multi-sym is a dotted symbol which refers to a table’s field. Returns a table containing each separate symbol, or false.
;;; * comment? - is the argument a comment? Comments are only included when opts.comments is truthy.
;;; * view - fennel.view table serializer.
;;; * get-scope - return the scope table for the current macro call site.
;;; * assert-compile - works like assert but takes a list/symbol as its third argument in order to provide pinpointed error messages.

(local type* (require :type))
;; (import-macros m :macros)

(local M {})

;;; debug

;; ref: https://stackoverflow.com/questions/9168058/how-to-dump-a-table-to-console
(fn _dump [o depth]
  (if (type*.table? o)
    (let [s ["{\n"]]
               (each [k v (pairs o)]
                 (table.insert s (.. depth "[" (tostring k) "] = " (_dump v (.. depth "  ")) ",\n")))
               (table.insert s "} ")
      (table.concat s ""))
    (tostring o)))

(fn M.dump [o]
  (print (_dump o "  ")))

;;; core {{{
;; nil: []

(fn M.car [x ...]
  x)

(fn M.cdr [x ...]
  [...])

(fn M.cons [x ...]
  [x  ...])

(fn M.atom [...]
  (= (select :# ...) 0))

;;; extension
(fn M.list [...]
  [...])

;;; }}}

;;; table {{{
(fn M.first [tbl]
  (M.car (table.unpack tbl)))

(fn M.rest [tbl]
  (M.cdr (table.unpack tbl)))

(fn M.pull [x xs]
  (M.cons x (table.unpack xs)))

(fn M.empty? [tbl]
  (M.atom (table.unpack tbl)))

;;; extesion

(fn M.append [tbl x]
  (if (M.empty? tbl)
             (M.pull x [])
             (M.pull (M.first tbl) (M.append (M.rest tbl) x))))

(fn M.last [tbl]
  (. tbl (length tbl)))

;; get n th element
(fn M.nth [n tbl]
  (if (= n 1)
             (M.first tbl)
             (M.nth (- n 1) (M.rest tbl))))

(fn M.length [tbl]
  (if (M.empty? tbl)
             0
             (+ 1 (length (M.rest tbl)))))

(fn M.find [x tbl]
  (if (M.empty? tbl)
             -1
             (if (= x (M.first tbl))
               1
               (+ 1 (M.find x (M.rest tbl))))))
;;; }}}


;;; higher-order functions {{{

(fn M.map [f tbl]
  (if (M.empty? tbl)
    []
    (M.pull
      (f (M.first tbl))
      (M.map f (M.rest tbl) ))))

(fn M.map2 [f tbl1 tbl2 ]
  (if (M.empty? tbl1)
    []
    (M.pull
      (f (M.first tbl1) (M.first tbl2))
      (M.map2 f (M.rest tbl1) (M.rest tbl2) ))))

(fn M.filter [f tbl ]
  (if (M.empty? tbl)
    []
    (if (f (M.first tbl))
      (M.pull (M.first tbl) (M.filter f (M.rest tbl) ))
      (M.filter f (M.rest tbl) ))))

(fn M.zip [tbl1 tbl2]
  (M.map2 #(M.list $1 $2) tbl1 tbl2))

(fn M.join [tbl1 tbl2]
  (if (M.empty? tbl2)
    tbl1
    (M.join (M.append tbl1 (M.first tbl2)) (M.rest tbl2))))

(fn M.foldl [f z tbl]
  (if (M.empty? tbl)
    z
    (M.foldl f (f z (M.first tbl)) (M.rest tbl))))

(fn M.foldr [f z tbl]
  (if (M.empty? tbl)
    z
    (f (M.first tbl) (M.foldr f z (M.rest tbl)))))

;;; }}}


;;; test

; (print (M.dump ["hoge" "foo" "bar"]))
; (M.dump (M.pull 3 []))
; (assert (= (M.first [2 3 4]) 2) "Err")
; (M.dump (M.rest [2]))
; (M.dump (M.pull 3 [2]))
; (M.dump (M.map #(+ $1 1) [2 3 4] ))
; (M.dump (M.map2 #(+ $1 $2) [2 3 4] [3 4 5] ))
; (M.dump (M.filter #(= $1 1) [2 3 1]))
; (M.dump (M.zip [2 3 4] [3 4 5] ))
; (M.dump (M.nth 5 [2 3 4 5]))
; (print (M.length [2 3 4 5]))
; (print (M.find 1 [2 3 4 5 4 8 0 0 0 1 0 ] ))
; (M.dump (M.join [1 2 3] [9 8 0]))
; (print (M.foldl #(+ $1 $2) 0 [1 3 4]))
; (print (M.foldr #(+ $1 $2) 0 [1 3 4]))

M
