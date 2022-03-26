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

(local t (require "util.src.type"))
(local l (require "util.src.list"))
(local ta (require "util.src.table1"))
(local o (require "util.src.object"))
(local s (require "util.src.string"))

(local M {})

;;; fn* {{{
(fn _keys-into-list [tbl]
  (var lst [])
  (each [key value (pairs tbl)]
    (set lst (l.append lst (sym key)))) lst)

(fn _insert-asserts2 [tbl]
  `(do ,(let  [keys (ta.keys-into-list tbl)
               vals (ta.vals-into-list tbl)]
          (unpack (l.map2 (lambda [k v] `(assert (= (type ,(sym k)) ,v) ,(.. "argument" k " must be " v))) keys vals )))))

(fn M.fn* [name types ...]
  "declare function with type annotation
  usage:
  ```
  (fn* {a :string}
    (print a))
  ``` "
  (assert-compile (not (t.string? name)) "fn* expects symbol, vector, or list as first arugument" name)
  (assert-compile (t.table? types) "fn* expects table as first arugment" types)
  `(fn ,name [,(unpack (_keys-into-list types))] (do  ,(_insert-asserts2 types) ,...)))
;;; }}}


;;; ref: https://notabug.org/dm9pZCAq/dotfiles/src/master/.config/nvim/fnl/macros.fnl

(fn M.for-n! [n tbl ...]
  "For i in range, do something."
  `(let [tbl# ,tbl]
     (for [,n 1 (length tbl#)]
       ,...)))

(fn M.for-n-i! [n-var i-var tbl ...]
  "Do same thing with for-n! but, also get table value when n=i"
  `(let [tbl# ,tbl]
     ,(M.for-n! n-var `tbl#)
     `(let [,i-var (. tbl# ,n-var)] ,...)))

(fn M.for! [i tbl ...] (M.for-n-i! `i# i tbl ...))

(fn M.push! [t i] `(test ,t (+ 1 (length ,t)) ,i))

(fn M.require* [relative absolute]
  "(local type* (require (if (empty? ...)
  :type
  :util.src.type)))"
  (fn empty? [s]
    (or (= s nil) (= s "")))
  `(require (if (empty? ...)
              ,relative
              ,absolute)))

(fn M.test* [body]
  "Test will be executed when called at root."
  (fn empty? [s]
    (or (= s nil) (= s "")))
  `(if (empty? ...)
     ,body))

M
