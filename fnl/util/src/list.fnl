;;;; Reference:
;;;; https://tomitomix.hatenablog.com/entry/2017/12/06/184950
;;;; https://github.com/andreyorst/fennel-cljlib/blob/master/init-macros.fnl

(local type* (require :util.src.type))

(local M {})

;;; debug {{{

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

;;; }}}

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

;; extension
(fn M.list [...]
  [...])

;;; }}}

;;; table {{{
(fn M.first [lst]
  (M.car (table.unpack lst)))

(fn M.rest [lst]
  (M.cdr (table.unpack lst)))

(fn M.pull [x xs]
  (M.cons x (table.unpack xs)))

(fn M.empty? [lst]
  (M.atom (table.unpack lst)))

;;; extesion

(fn M.append [lst x]
  (if (M.empty? lst)
             (M.pull x [])
             (M.pull (M.first lst) (M.append (M.rest lst) x))))

(fn M.last [lst]
  (. lst (length lst)))

;; get n th element
(fn M.nth [n lst]
  (if (= n 1)
             (M.first lst)
             (M.nth (- n 1) (M.rest lst))))

(fn M.length [lst]
  (if (M.empty? lst)
             0
             (+ 1 (length (M.rest lst)))))

(fn M.find [x lst]
  (if (M.empty? lst)
             -1
             (if (= x (M.first lst))
               1
               (+ 1 (M.find x (M.rest lst))))))

(fn M.in? [x lst]
  (if (M.empty? lst)
             false
             (or (= x (M.first lst)) (M.in? x (M.rest lst)))))
;;; }}}


;;; higher-order functions {{{

(fn M.map [f lst]
  (if (M.empty? lst)
    []
    (M.pull
      (f (M.first lst))
      (M.map f (M.rest lst) ))))

(fn M.map2 [f lst1 lst2 ]
  (if (M.empty? lst1)
    []
    (M.pull
      (f (M.first lst1) (M.first lst2))
      (M.map2 f (M.rest lst1) (M.rest lst2) ))))

(fn M.filter [f lst ]
  (if (M.empty? lst)
    []
    (if (f (M.first lst))
      (M.pull (M.first lst) (M.filter f (M.rest lst) ))
      (M.filter f (M.rest lst) ))))

(fn M.zip [lst1 lst2]
  (M.map2 #(M.list $1 $2) lst1 lst2))

(fn M.join [lst1 lst2]
  (if (M.empty? lst2)
    lst1
    (M.join (M.append lst1 (M.first lst2)) (M.rest lst2))))

(fn M.foldl [f z lst]
  (if (M.empty? lst)
    z
    (M.foldl f (f z (M.first lst)) (M.rest lst))))

(fn M.foldr [f z lst]
  (if (M.empty? lst)
    z
    (f (M.first lst) (M.foldr f z (M.rest lst)))))

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
; (print (M.in? 3 [2 1 4]))

M
