;;;; Reference:
;;;; https://tomitomix.hatenablog.com/entry/2017/12/06/184950
;;;; https://github.com/andreyorst/fennel-cljlib/blob/master/init-macros.fnl

(local (module-name file-name) ...)
(local unpack (or table.unpack _G.unpack))

(fn empty? [s]
  (or (= s nil) (= s "")))

(local type* (require (if (empty? module-name)
               :type
               :util.type)))

(local M {})

;;; debug {{{

;; ref: https://stackoverflow.com/questions/9168058/how-to-dump-a-table-to-console
(fn _dump [o depth]
  "dump the object"
  (if (type*.table? o)
    (let [s ["{\n"]]
               (each [k v (pairs o)]
                 (table.insert s (.. depth "  [" (tostring k) "] = " (_dump v (.. depth "  ")) ",\n")))
               (table.insert s (.. depth "} "))
      (table.concat s ""))
    (tostring o)))

(fn M.dump [o]
  (print (_dump o "")))

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
  "use as car"
  (M.car (unpack lst)))

(fn M.rest [lst]
  "use as cdr"
  (M.cdr (unpack lst)))

(fn M.pull [x xs]
  "use as cons"
  (M.cons x (unpack xs)))

(fn M.empty? [lst]
  (M.atom (unpack lst)))

;;; extesion

(fn M.append [lst x]
  (if (M.empty? lst)
             (M.pull x [])
             (M.pull (M.first lst) (M.append (M.rest lst) x))))

(fn M.last [lst]
  (. lst (length lst)))

(fn M.nth [n lst]
  " get n-th element"
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

;; unfold
;; 1. apply `func` to `seed`.
;; 2. insert return value of `func` into list.
;; 3. update `seed` with `iterate-update`
;; 4. ...
(fn M.unfold [condition func iterate-update seed]
  (if (condition seed)
     []
     (M.pull (func seed) (M.unfold condition func iterate-update (iterate-update seed)))))

;; like do-while
(fn M.unfold-iter2 [condition func iterate-update seed]
  (let [v (func seed)]
    (if (condition v)
      []
      (M.pull v (M.unfold-iter2 condition func iterate-update (iterate-update seed))))))

(fn M.unfold-iter [seed ?object ?finish]
  " unfold the iterator
  example:
  ```fennel
  (local p (io.popen ))
  (list.unfold-iter (p.lines p) p (lambda [x] (io.close x))))
  ``` "
  (let [v (seed)]
    (if (= nil v)
    (do
      (when (and (not= ?finish nil) (not= ?object nil))
        (?finish ?object))
      [])
    (M.pull v (M.unfold-iter seed ?object ?finish)))))

(fn M.reverse [lst]
  (if (M.empty? lst)
    []
    (M.append (M.rest lst) (M.first lst))))

(fn M.pick-n [lst n]
  "pick 2 [2 3 4] -> [2 3]"
  (if (= n 0)
    []
    (M.pull (M.first lst) (M.pick-n  (M.rest lst) (- n 1)))))

(fn M.subseq [lst start end]
  "(subseq [3 4 6 6] 1 2) -> [3 4]"
  "(subseq [3 4 6 7] 3 4) -> [6 7]"
  (if (= start (+ end 1))
    []
    (M.pull (M.nth start lst) (M.subseq lst (+ start 1) end))))
;;; }}}

(fn M.range [x]
  "generate list: (1 ... x)"
  (M.unfold (lambda [y] (= y (+ x 1))) (lambda [y] y) #(+ $1 1) 1))

(fn M.choice [tbl]
  "pick element randomly from table"
  (M.nth (math.random 1 (M.length tbl)) tbl))

(fn M.?->table [?]
  "return table"
  (if (= (type ?) :table)
    ?
    [?]))

(fn M.concat* [xs ?d]
  "concatenate xs with d"
  (let [d (or ?d "")]
    (if (= (type xs) :table)
      (table.concat xs d)
     xs)))

(fn M.concat-with [d ...]
  (table.concat [...] d))

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
; (M.dump (M.reverse [2 3 4 4 5 8]))
; (M.dump (M.unfold #(= $1 0) (lambda [x] x) (lambda [x] (- x 1)) 3))
; (print (M.foldl #(+ $1 $2) 0 (M.unfold #(= $1 0) (lambda [x] x) (lambda [x] (- x 1)) 3)))
; (print (M.choice [3 4 5 6]))
; (M.dump (M.range 4))
; (M.dump (M.pick-n [3 4 6 6 ] 2))
; (M.dump (M.subseq [3 4 6 6 ] 1 2))
; (M.dump (M.subseq [3 4 6 6 ] 3 4))

M
