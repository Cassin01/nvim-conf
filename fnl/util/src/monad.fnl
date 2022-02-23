;; ref https://gist.github.com/pwarren0/cf062be8ee7546756165
(local o (require  :util.src.object))
(local l (require  :util.src.list))
(local t (require  :util.src.type))
(local t1 (require :util.src.table1))

; (local just {})
; (local none {})

(local M {})

(fn M.type* [o]
  (if (t.table? o)
    (o.getmetadata o :__name)
    (type o)))

;;; typ-class

(local type-class (o.override o "type-class"))

;;; functor

(local functor (type-class.override type-class :functor))

;; (a -> b) -> t a -> t b
(fn functor.new [self f ta]
  (let [tb (o.deepcopy ta)]
    (if (t1.in? :core tb)
      (tset tb :core (f (. tb :core)))
      ;; return ta (but this is not functor aim to)
      tb)))

;;; monad

(local monad (type-class.override type-class :monad))

;; m a -> a
(fn monad.return [self ma]
  (let [ma_ (o.deepcopy ma)]
    (if (t1.in? :core ma_)
      (. ma_ :core)
      ma_)))

;; m a -> (a -> m b) -> m b
(fn monad.bind [self ma f]
  (let [mb (o.deepcopy ma)]
    (if (t1.in? :core ma)
      (tset mb :core (. ma :core)))
    mb))

(local just (o.override
              o
              :just))

(fn just.new [self core]
  (let [obj (o.deepcopy self)]
    (tset obj :core core) obj))

(local none (o.override
              o
              :none))


(local option (o.override
                o
                :option))


;(l.dump option)
;(fn option.return [self core]
;  (just.new core))

;;; IDEA : type class
;; what will be required for type class?
;; - virtual function
