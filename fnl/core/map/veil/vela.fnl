(local vf vim.fn)
(local va vim.api)

;;; vela (inspired by easy-motion avy.el light-speed leap) {{{
(fn mini-win-open [row col char win]
  (let [buf (va.nvim_create_buf false true)
        win (va.nvim_open_win buf true {:col col
                                        :row row
                                        :win win
                                        :relative :win
                                        :anchor :NW
                                        :style :minimal
                                        :height 1
                                        :width 1
                                        :border :none})]
    (va.nvim_buf_set_lines buf 0 -1 true [char])
    (vf.matchaddpos :IncSearch [1])
    ; (va.nvim_win_set_option win :winblend 10)
    [buf win]))

(fn mini-win-close [buf win]
  (va.nvim_win_close win true)
  (va.nvim_buf_delete buf {:force true}))

(fn str2list [str]
  (var list [])
  (var len 0)
  (for [i 1 (string.len str)]
    (set len (+ len 1))
    (tset list i (string.sub str i i)))
  (values list len))

(fn list2str [list]
  (var res "")
  (each [i v (ipairs list)]
    (set res (.. res v)))
  res)

(fn vela-search [nr line]
  (var ret [])
  (let [l (str2list line)]
    (each [i v (ipairs l)]
      (if (= v (vf.nr2char nr))
        (table.insert ret i))))
  ret)

(fn sub-list [list start end]
  (var ret [])
  (local till (if (<= (length list) end) (length list) end))
  (for [i start till]
    (table.insert ret (. list i)))
  ret)

(fn input-a-char []
  (var ?done false)
  (var ret nil)
  ; (while (not ?done)
    (when (vf.getchar true)
      (let [nr (vf.getchar)]
        (set ?done true)
        (set ret nr)))
    ; )
  (vf.nr2char ret))

(fn cons [x ...]
  [x  ...])

(fn remove-duplicates [core list]
  (var tmp {})
  (each [i v (ipairs core) ]
    (tset tmp v i))
  (each [i v (ipairs list) ]
    (tset tmp v nil))
  (var ret [])
  (each [i v (pairs tmp)]
    (table.insert ret i))
  ret)

(fn pull [x xs]
  "use as cons"
  (cons x (unpack xs)))

(fn vela-match [hash matched-str win pos p]
  (let [pos (. hash (string.sub matched-str 1 p))]
    (if (not= pos nil)
      (do
        (va.nvim_win_set_cursor win [(. pos 1) (- (. pos 2) 1)])
        true)
      (if (< p 1)
        false
        (vela-match hash matched-str win pos (- p 1))))))

(fn vela-core [win buf nr]
  (local first-line (- (vf.line :w0 win) 1))
  (local last-line (vf.line :w$ win))
  (local lines (va.nvim_buf_get_lines buf first-line last-line  true))

  ;; get positions
  (var matched-pos {})
  (each [lnum line (ipairs lines)]
    (local search-res (vela-search nr line))
    (each [_ col (ipairs search-res)]
      (local target (list2str (sub-list (str2list line) col (+ col 1))))
      (when (and (not= target "") (not= target nil))
        (if (= (. matched-pos target) nil)
          (tset matched-pos target [[lnum col]])
            (tset matched-pos target (pull [lnum col] (. matched-pos target)))))))

  ;; generate hashed dict
  ; (print (vim.inspect matched-pos))
  (var hash {})
  (local suffixs (str2list "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"))
  (var escape-suffixs-2 [])
  ; (var escape-suffixs-1 [])
  (var uniqe-candidate-ids [])
  (each [prefix poss (pairs matched-pos)]
    (when (= (length poss) 1) ; when the candidate is unique
      (local pos (. poss 1))
      (tset hash prefix pos)
      (local plist (str2list prefix))
      (when (= (length plist) 2)
        (let [therd-char (. plist 2)
              row (. pos 1)
              col (. pos 2)]
          ; (table.insert uniqe-candidate-ids (vf.matchaddpos :Todo [(- row 1) (- col) 1]))
          (table.insert escape-suffixs-2 therd-char)))
      (when (= (length plist) 1)
        (let [second-char (. plist 1)
              row (. pos 1)
              col (. pos 2)]
          ; (table.insert uniqe-candidate-ids (vf.matchaddpos :Todo [(- row 1) (- col) 0]))
          (table.insert escape-suffixs-2 second-char)))))

  (local actual-suffixes-2 (remove-duplicates suffixs escape-suffixs-2))
  (local actual-suffixes-len (length actual-suffixes-2))
  (local left-shift-size (. (. (vf.getwininfo win) 1) :textoff))
  ; (print (vim.inspect (vf.getwininfo win)))
  (var iter 1)
  (var arbitrary-candidate-ids [])
  (each [prefix poss (pairs matched-pos)]
    (when (not= (length poss) 1)
      (each [i pos (ipairs poss)]
        (when (<= iter actual-suffixes-len)
          (local suffix (. actual-suffixes-2 iter))
          (local (row col) (values (. pos 1) (. pos 2)))
          (table.insert
            arbitrary-candidate-ids
            (mini-win-open (- row 1)
                           (+ (- col 1) left-shift-size (length (str2list prefix)))
                           suffix win))
          (tset hash (.. prefix suffix) pos)
          (set iter (+ iter 1))))))
  (va.nvim_win_set_cursor win (va.nvim_win_get_cursor win))

  (var input (input-a-char))
  (let  [matched-str (.. (vf.nr2char nr) input)]
    (if (vela-match hash matched-str win pos 2)
      (do
        (each [_ i (ipairs arbitrary-candidate-ids)]
          (mini-win-close (unpack i)))
        (each [_ id (ipairs uniqe-candidate-ids)]
          (vf.matchdelete id win)))
      (do
        (var input (.. input (input-a-char)))
        (each [_ i (ipairs arbitrary-candidate-ids)]
          (mini-win-close (unpack i)))
        (each [_ id (ipairs uniqe-candidate-ids)]
          (vf.matchdelete id win))
        (let  [matched-str (.. (vf.nr2char nr) input)]
          (vela-match hash matched-str win pos 3)))))
  ; (var input (.. input (input-a-char)))
  ; (each [_ i (ipairs arbitrary-candidate-ids)]
  ;   (mini-win-close (unpack i)))
  ; (each [_ id (ipairs uniqe-candidate-ids)]
  ;   (vf.matchdelete id win))
  ; (let  [matched-str (.. (vf.nr2char nr) input)]
  ;   (vela-match hash matched-str win pos 3))
)

(fn vela0 []
  (local win (va.nvim_get_current_win))
  (local buf (va.nvim_get_current_buf))
  (var done? fasle)
  (while (not done?)
    (when (vf.getchar true)
      (let [nr (vf.getchar)]
        (set done? true)
        (when (not= nr 27)
          (vela-core win buf nr))))))

;;; vela

(fn vela []
  (print :called)
  (local win (va.nvim_get_current_win))
  (local buf (va.nvim_get_current_buf))
  (var done? false)
  (var count 1)
  (var ids [])
  (while (not done?)
    (when (vf.getchar true)
      (let [nr (vf.getchar)]
        (table.insert ids (mini-win-open 1 count (vf.nr2char nr) win))
        (set count (+ count 1))
        (when (= count 5)
          (each [_ i (ipairs ids) ]
            (mini-win-close (unpack i)))
          (set done? true)
          (print count))))))
;;; }}}

{: vela : vela0}
