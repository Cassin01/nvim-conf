;;;; Reference:
;;;; https://tomitomix.hatenablog.com/entry/2017/12/06/184950
;;;; https://github.com/andreyorst/fennel-cljlib/blob/master/init-macros.fnl
(local M {})

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

(fn M.table? [o]
  (= (type o) "table"))

(fn M.number? [o]
  (= (type o) "number"))


;;; debug

;; ref: https://stackoverflow.com/questions/9168058/how-to-dump-a-table-to-console
(fn _dump [o depth]
  (if (M.table? o)
    (let [s ["{\n"]]
               (each [k v (pairs o)]
                 (table.insert s (.. depth "[" (tostring k) "] = " (_dump v (.. depth "  ")) ",\n")))
               (table.insert s "} ")
      (table.concat s ""))
    (tostring o)))


(fn M.dump [o]
  (print (_dump o "  ")))

;;; core
;; nil: []
;; atom: [x]

(fn M.car [x ...]
  x)

(fn M.cdr [x ...]
  [...])

(fn M.cons [x ...]
  [x  ...])

(fn M.atom [...]
  (= (select :# ...) 0))

;;; table

(fn M.first [tbl]
  (M.car (table.unpack tbl)))

(fn M.rest [tbl]
  (M.cdr (table.unpack tbl)))

(fn M.pull [x xs]
  (M.cons x (table.unpack xs)))

(fn M.empty [tbl]
  (M.atom (table.unpack tbl)))

;;; higher-order functions

(fn M.map [tbl f]
  (if (M.empty tbl)
    []
    (M.pull
      (f (M.first tbl))
      (M.map (M.rest tbl) f))))

;;;; test

;; (print (M.dump ["hoge" "foo" "bar"]))
;; (M.dump (M.pull 3 []))
(assert (= (M.first [2 3 4]) 2) "Err")

(M.dump (M.rest [2]))

(print (= [] []))

;; (M.dump (M.pull 3 [2]))

(M.dump (M.map [2 3 4] #(+ $1 1)))

M
