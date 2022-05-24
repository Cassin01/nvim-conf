(local {: goto-line
        : universal-argument
        : inc-search
        : retrive_till_tail
        : retrive_first_half} (require :core.map.veil.source))

(macro m [c ?s]
  (let [s (or ?s "")]
    (.. (string.format :<M-%s> c) s)))

(macro m-s [c]
  (string.format :<M-S-%s> c))

(macro c [c ?s]
  (let [s (or ?s "")]
    (.. (string.format :<C-%s> c) s)))

(macro s [c]
  (string.format :<S-%s> c))

(macro c-s [c]
  (string.format :<C-S-%s> c))

(macro normal! [c]
  (string.format "<cmd>normal! %s<cr>" c))

;;; ----------------------------------------------------------------------

(fn _translate-arg [key cmd desc]
  (if (= (type cmd) :string)
    [0 :i key cmd {:noremap true :silent true :desc desc}]
    [0 :i key "" {:callback cmd :noremap true :silent true :desc desc}]))

;;; WARN: I personally not prefer using reserved keys.
;;; C-m, C-i, C-h, (C-t, C-d)

;;; IDEA: I searching more vim like way.
;;; So we call `vela`
;;; Reserved:
;;; C-m, C-i, C-h, (C-t, C-d)
;;; C-t, C-d,
;;; C-j, C-k, C-l, C-h
;;; Acually
;;; - m,i,h
;;; - Not Used
;;; - Move: c-f, c-b, c-k, c-l
;;; - Indent: c-t, c-d
;;; - Add line: c-o c-j
;;; - Word Jump: c-w +
;;; - EOL, BOL: c-a, c-e
;;; - save: c-s
;;; - redo: c-r
;;; - undo: c-u
;;; - yank: c-y
;;; Now lest...
;;; c, g, q, v, x, z
;;; Page: c-p
;;; c-g+c-g, c-g+g, c-g+c-s


(let
  [map-data
   [
    ;; move
    [(c :b) :<left> "Left"]
    [(c :f) :<right> "Right"]
    [(c :a) :<c-o>^ "Jump to BOL"] ; *
    [(c :e) :<end> "Jump to EOL"]
    [(c :j) :<esc>o "<C-j> insert new line bellow and jump"]
    [(c :o) :<esc>O "<C-o> insert new line above and jump"] ; *
    [(m :g :g) goto-line "Goto line"]
    ; [(c :g) goto-line "Goto line"]
    [(c :u) universal-argument :universal-argument] ; *
    [(c :p) :<up> "Up"]
    [(c :n) :<down> "Down"]
    [(m :f) :<s-right> "Right"]
    [(m :b) :<s-left> "Left"]
    [(c :v) :<c-o><c-b> "Page down"]
    [(m :v) :<c-o><c-f> "Page up"]
    [(m :<) :<esc>ggi "Beginning of buffer"]
    [(m :>) :<c-o>G "End of buffer"]
    [(c :s) inc-search "Search"]
    [(c :l) "<c-o><Plug>(leap-forward)" "leap-forward"]
    [(c :i) "<c-o><Plug>(leap-backward)" "leap-backword"]

    ;; edit
    [(c :d) :<Del> "Delete"] ; * ; <- I actually use default i_CTRl-D.
    [(m :h) :<esc>vbc "Delete previous word"]
    [(m :d) :<esc>wvec "Delete next word"]
    [(c :k) retrive_till_tail "delete from cursor to EOL"] ; *
    [(c-s :k) retrive_first_half "delete from cursor to BOL"]
    [(c :t) :<esc>xphli :transpose-chars] ; *
    [(m :t) :<esc>dwea<space><esc>pa<bs> :transpose-words]
    [(.. (c :x) (c :t)) :<esc>ddpi :transpose-lines] ; *

    ;; case
    [(m :u) "<esc>llbgUwi" :uppercase-word]
    [(m :l) "<esc>llbguwi" :lowercase-word]
    [(m :c) "<esc>llbvui" :capitalcase-word]

    ;; comment
    [(m ";") "<esc>:execute \"normal \\<plug>CommentaryLine\"<cr>i"
     "Comment line"]

    ;; copy & paste
    [(c :c) "<c-o>v" "mark the start point of yank"] ; *
    [(c :y) "<esc>pa" "paste"] ; *

    ;; undo & redo
    [(c :z) "<esc>ua" "undo"] ; *
    [(c-s :z) "<esc><c-r>a" "redo"]

    ;; window
    [(c :x :0) "<c-o><c-w>q" "Close a window"]
    [(c :x :1) "<c-o>:<c-u>only<cr>" :delete-other-windows]
    [(c :x :2) "<c-o>:<c-u>vs<cr>" :split-vertically]
    [(c :x :3) "<c-o>:<c-u>sp<cr>" :split-horizontally]
    [(c :x :o) "<c-o><c-w>w" "Move to other windows"]
    [(c :x :k) "<c-o>:bdelete<cr>" "Kill buffer"] ; *
    [(c :x :j) "<c-o>:Telescope buffers<cr>"]

    ;; file
    [(.. (c :x) (c :s)) "<c-o>:update<cr>" :save-file]
    ]]
  (icollect [_ k (ipairs map-data)]
            (_translate-arg (unpack k))))
