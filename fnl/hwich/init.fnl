(local {: map} (require :kaza.map))
(local {: warn : exec} (require :kaza.file))
(local {: nr2char : getchar : feedkeys : getpos : setpos : cursor
        : getline : col } vim.fn)
(local {: nvim_exec} vim.api)

(local util (require :util.src))
(local o util.object)
(local l util.list)


;;; key-binds

;; specified functions

;; [bufnum, lnum, col, off]
(fn move-pos [row col]
  (var pos (getpos "."))
  (local c-row (. pos 2))
  (local c-col (. pos 3))
  (cursor (+ c-row row)
          (+ c-col col))
  )

(set _G.key-binds [])
(local key-bind (o.override {} :key-bind (lambda [key f] {:key key :f f})))
(table.insert _G.key-binds (key-bind.new [2] (lambda [] (do
                                                      (vim.cmd "stopinsert")
                                                      (feedkeys "h" "it")
                                                      ""))))
(table.insert _G.key-binds (key-bind.new [14] (lambda [] (do
                                                      (vim.cmd "stopinsert")
                                                      (feedkeys "j" "it")
                                                      ""))))
(table.insert _G.key-binds (key-bind.new [6] (lambda [] (do
                                                      (vim.cmd "stopinsert")
                                                      (feedkeys "l" "it")
                                                      ""))))
(table.insert _G.key-binds (key-bind.new [16] (lambda [] (do
                                                      (vim.cmd "stopinsert")
                                                      (feedkeys "h" "it")
                                                      ""))))

;;;

(fn _key-match [index c]
  "-> list"
  (l.filter (lambda [x] (= (. (. x :key) index) 2)) _G.key-binds))

(fn _do? [c]
  "-> string"
  (if (= (length (_key-match 1)) 1)
    ((. (. (_key-match 1) 1) :f))
    "not matched"))

(fn _getchar []
  (local wlf (require "wlfloatline"))
  (wlf.stop_runner)
  (local c (getchar))
  (wlf.start_runner)
  c)

(fn _current_input []
  (if (vim.fn.getchar 1)
    (_getchar)
    ""))

(fn _current_input2 []
  (local wlf (require "wlfloatline"))
  (wlf.stop_runner)
  (local c (getchar 0))
  (wlf.start_runner)
  c)

;(fn _insert_char [c]
;  (let  [ cmd (.. "normal \"a" c "\"")]
;  (vim.cmd cmd))
;  "")
;(fn _insert_char [n]i
;  (let [c (nr2char n)
;        line (getline ".")
;        ])
;  )

(fn _controller []
  (let [c (_current_input)]
    (print c)
    (match c
      (a ? (= a 13)) "" ;; CR (C-m)
      (a ? (and (> a 0) (< a 32))) (do (feedkeys "i111") (_do? a ))
      (a) (do (feedkeys "111") (nr2char a))
      )))

(fn _G.hwich_start []
  (_controller))

(map "i" "111" "v:lua.hwich_start()" {:noremap true :expr true :nowait true})

{}

;; https://vim.fandom.com/wiki/Wait_for_user_input_(getchar)_without_moving_cursor
