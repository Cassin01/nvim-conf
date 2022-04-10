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

(local M {})

(fn M.def [name args types ...]
  "examples:
  ```fennel
  (def add [a b] [:number :number :number] (+ a b))
  (def 2str [obj] [:any :string] ...)
  (def opt [?a] [:?number :number] ...)
  (def len [obj] [[:table :string] :number] ...)
  (def add [x ...] [:number :varg :number])
  ```"
  (assert-compile (not (= (type name) :string)) "name expects symbol, vector, or list as first arugument" name)
  (assert-compile (= (type types) :table) "types expects table as first arugment" types)
  `(fn ,name [,(unpack args)] 
     (let [first# (λ [lst#] (. lst# 1))
           rest# (λ [lst#] [(unpack lst# 2)])
           empty?# (λ [str#] (or (= str# nil) (= str# "")))
           type?# (λ [?obj# type#] (if (= type# :any) true (= (type ?obj#) type#)))
           type-eq# (λ  [?actual# expect#]
                      (match (type expect#)
                        :string (if (let [res# (string.match expect# "^?")]
                                      (or (= res# nil) (= res# "")))
                                  (type?# ?actual# expect#)
                                  (or (type?# ?actual# (string.match expect# "%w+"))
                                      (type?# ?actual# :nil)))
                        :table (or (= (type ?actual#) (first# expect#)) (type-eq# actual# (rest# expect#)))
                        _# false))]
       ,(icollect [i# k# (ipairs args)]
                  (if (< i# (length types))
                    (if (varg? k#)
                      (assert-compile (= :varg (. types i#)) "[type mismatch] ... expects :varg" types)
                      `(assert (type-eq# ,k# ,(. types i#))
                               (.. "argument " (tostring ,k#) "[type mismatch] must be " ,(. types i#))))
                    (assert-compile false "too many arguments" args)))
       (let [ret# (do ,...)]
         (assert (type-eq# ret# ,(. types (length types))) (.. "return value must be " ,(. types (length types)) " but " (type ret#)))
         ret#))))

(fn M.ep [k v source body]
  "each pairs"
  `(each [,k ,v (pairs ,source)]
    ,body))

(fn M.epi [i v source body]
  "each ipairs"
  `(each [,i ,v (ipairs ,source)]
    ,body))

(fn M.req-f [f m]
       `(. (require ,m) ,f))
(fn M.ref-f [f m ...]
  `((. (require ,m) ,f) ,...))

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
  :util.type)))"
  (fn empty?# [s]
    (or (= s nil) (= s "")))
  `(require (if (empty?# ...)
              ,relative
              ,absolute)))

(fn M.test* [body]
  "Test will be executed when called at root."
  (fn empty?# [s]
    (or (= s nil) (= s "")))
  `(if (empty?# ...)
     ,body))

M
