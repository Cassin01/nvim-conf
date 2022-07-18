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


;;; utility functions

(fn M.nil? [o]
  (= o nil))

(fn M.table? [o]
  (= (type o) :table))

(fn M.number? [o]
  (= (type o) :number))

(fn M.string? [o]
  (= (type o) :string))

;;; def

(fn _2str [obj]
  "obj: string or table"
  (if
    (= (type obj) :table) (table.concat obj " or ")
    (= (type obj) :string) obj
    (assert false "expected string or table")))

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
     (let [rest# (λ [lst#] [(unpack lst# 2)])
           empty?# (λ [str#] (or (= str# nil) (= str# "")))
           type?# (λ [?obj# type#] (if (= type# :any) true (= (type ?obj#) type#)))]
           (fn type-eq# [?actual# expect#]
                      (match (type expect#)
                        :string (if (let [res# (string.match expect# "^?")]
                                      (or (= res# nil) (= res# "")))
                                  (type?# ?actual# expect#)
                                  (or (type?# ?actual# (string.match expect# "%w+"))
                                      (type?# ?actual# :nil)))
                        :table (or (= (type ?actual#) (. expect# 1)) (type-eq# ?actual# (rest# expect#)))
                        _# false))
       ,(icollect [i# k# (ipairs args)]
                  (if (< i# (length types))
                    (if (varg? k#)
                      (assert-compile (= :varg (. types i#)) "[type mismatch] ... expects :varg" types)
                      `(assert (type-eq# ,k# ,(. types i#))
                               (.. "argument " (tostring ,k#) "[type mismatch] must be " ,(_2str (. types i#)) " but " (type ,k#))))
                    (assert-compile false "too many arguments" args)))
       (let [ret# (do ,...)]
         (assert (type-eq# ret# ,(. types (length types))) (.. "return value must be " ,(_2str (. types (length types))) " but " (type ret#)))
         ret#))))

(fn M.ep [k v source ...]
  "each pairs"
  `(each [,k ,v (pairs ,source)]
    ,...))

(fn M.epi [i v source ...]
  "each ipairs"
  `(each [,i ,v (ipairs ,source)]
    ,...))

(fn M.req-f [f m]
       `(. (require ,m) ,f))

(fn M.ref-f [f m ...]
  `((. (require ,m) ,f) ,...))

(fn M.unless [cond ...]
  `(if (not ,cond) ,...))

(fn M.until [cond ...]
  `(while (not ,cond) ,...))

(fn M.return [res]
  `(lua ,(.. "return " (tostring res))))

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
