; (local {: goto-line
;         : universal-argument
;         : inc-search
;         : kill-line2end
;         : kill-line2begging} (require :emacs-key-source))
(fn rt [str]
  (vim.api.nvim_replace_termcodes str true true true))

(local jump_col
  (lambda [direction_]
    (lambda []
      (local D {:forward :forward
                :backward :backward})
      (var cm -1)
      (var gm {})
      (local input_
        (lambda []
          (while true
            (when (vim.fn.getchar 1)
              (local c_ (vim.fn.getchar ))
              ; (local ret (vim.fn.nr2char c_))
              (lua "return c_")))))
      (local input
        (lambda []
          (vim.fn.nr2char (input_))))
      (local f_
        (lambda [c_ direction]
          (local gfindc (. (require :lua.util) :gfindc))
          (local findc (. (require :lua.util) :findc))
          (local lnum (vim.fn.line "."))
          (local col (vim.fn.col "."))
          (local line_ (vim.api.nvim_get_current_line))
          (local d
            (if (= direction D.forward)
              (findc (string.sub line_ (+ col 1) (length line_)) c_)
              (findc (string.reverse (string.sub line_ 1 (- col 1))) c_)))
          (if (= d nil)
            1 ; failed to search char
            (do
              (each [_ v (ipairs (gfindc line_ c_))]
                (table.insert gm (vim.fn.matchaddpos "CurSearch" [[lnum v 1]] )))
              (if (= direction D.forward)
                (do
                  (vim.fn.cursor lnum (+ d col))
                  (set cm (vim.fn.matchaddpos "Cursor" [[lnum (vim.fn.col ".") 1]] )))
                (do
                  (vim.fn.cursor lnum (- col d))
                  (set cm (vim.fn.matchaddpos "Cursor" [[lnum (vim.fn.col ".") 1]] ))))
              (vim.cmd "redraw!")
              0))))
      (fn core [c_ direction]
        (local res (f_ c_ direction))
        (when (= res 0)
          (local i_ (input_))
          (when (not= cm -1)
            (vim.fn.matchdelete cm))
          (each [i v (ipairs gm)]
            (vim.fn.matchdelete v))
          (set gm {})
          (if
            (= i_ 6)
            (core c_ D.forward)
            (= i_ (rt "<c-s-f>"))
            (core c_ D.backward)
            ; (vim.fn.nr2char i_)
            (vim.api.nvim_feedkeys (vim.fn.nr2char i_) :i false)
            )))
      (local c_ (input))
      (core c_ direction_))))
(vim.api.nvim_set_keymap "i" :<c-f> "" {:desc :normal-f
                                        :noremap true
                                        :silent true
                                        ; :expr true
                                        :callback (jump_col :forward)})
(vim.api.nvim_set_keymap "i" :<c-s-f> "" {:desc :normal-F
                                          :noremap true
                                          :silent true
                                          ; :expr true
                                          :callback (jump_col :backward)})
    ; [(c :f) (jump_col :forward) "normal-f"]
    ; [(c-s :f) (jump_col :backward) "normal-F"]

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
;;; C-m, C-i, C-h, (C-t, C-d), C-o

;;; IDEA: I searching more vim like way.
;;; So we call `vela`
;;; Reserved:
;;; - C-m, C-i, C-h, (C-t, C-d)
;;; - C-t, C-d,
;;; - C-j, C-k, C-l, C-h
;;; Acually:
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

;;; IDEA: Use c-{num} instead of c-u
;;; IDEA: Cefine command insertion frame work

;;; EXCEPTION: I'm not prefer to make short cut on Insert-mode for bellow commands.
;;; - case Change
;;;    - Because We can't expect any key efficiency.

;;; TODO: Key reloading (auto reloading would be great)
;;; TODO: Key map not reloading well detector (Not necessary)
;;; TODO: File type white list or black list

(let
  [map-data
   [
    ;; move
    ; [(c :0) (λ []
    ;           (fn setup-buffer [enabled]
    ;             ((. (. (require :cmp) :setup) :buffer) {:enabled enabled}))
    ;           (if (= vim.b.cmp-disable nil)
    ;             (do (tset vim.b :cmp-disable true)
    ;               (setup-buffer true))
    ;             (do (tset vim.b :cmp-disable nil)
    ;               (setup-buffer false)))
    ;           ) "toggle cmp"]
    ; [(c :b) :<left> "Left"]
    ; [(c :f) :<right> "Right"]
    ; [(c :f) :<c-o>f "normal-f"]
    ; [(c-s :f) :<c-o>F "normal-F"]
    [(c :a) :<c-o>^ "Jump to BOL"] ; *
    [(c :e) :<end> "Jump to EOL"]
    ; [(c :j) :<esc>o "<C-j> insert new line bellow and jump"]
    ; [(c :j) (lambda []
    ;           ; 102 eisu
    ;           ; 104 kana
    ;           (if (= vim.g.ime_on true) ; nil or  true
    ;             (do ; ime off
    ;               (local script "osascript -e \"tell application \\\"System Events\\\" to key code 102\"")
    ;               (vim.fn.system script)
    ;               (vim.cmd "highlight iCursor guibg=#5FAFFF cterm=underdotted")
    ;               (vim.cmd "set guicursor+=i:var25-iCursor")
    ;               (tset vim.g :ime_on false))
    ;             (do ; ime on
    ;               (local script "osascript -e \"tell application \\\"System Events\\\" to key code 104\"")
    ;               (vim.fn.system script)
    ;               (vim.cmd "highlight iCursor guibg=#cc6666")
    ;               (vim.cmd "set guicursor+=i:var25-iCursor")
    ;               (tset vim.g :ime_on true))))
    ;  "ime toggle"]
    [(c-s :o) :<esc>O "<C-S-o> insert new line above and jump"] ; *
    ; [(c :o) :<esc>o "<C-o> insert new line above and jump"]
    ; [(c :g ::) goto-line "Goto line"] ; migrated
    ; [(c :u) universal-argument :universal-argument] ; *
    ; [(c :p) :<up> "Up"]
    ; [(c :n) :<down> "Down"]
    [(m :l) :<s-right> "Right"]
    [(m :k) :<s-left> "Left"]
    [(m :b) :<c-o><c-b> "Page down"]
    [(m :f) :<c-o><c-f> "Page up"]
    [(c :g :g) :<esc>ggi "Beginning of buffer"]
    [(c :g :G) :<c-o>G "End of buffer"]
    ; [(c :s) inc-search "Search"]
    [(c-s :l) "<c-o><Plug>(leap-backward)" "leap-backward"]
    [(c :l) "<c-o><Plug>(leap-forward)" "leap-forward"]

    ;; edit
    ; [(c :d) :<Del> "Delete"] ; * ; <- I actually use default i_CTRl-D. ; TODO: Find a key that replace this
    [(c-s :h) :<Del> "Delete"]
    ; [(m :h) :<esc>vbc "Delete previous word"] ; -> ctrl-w
    [(c-s :w) :<esc>vec "Delete next word"]
    ; [(c-s :u) kill-line2end "delete from cursor to EOL"] ; *
    ; [(c-s :k) kill-line2begging "delete from cursor to BOL"]
    ; [(c :t) :<esc>xphli :transpose-chars] ; * ; TODO: find a key that replace this
    [(m :t) :<esc>dwea<space><esc>pa<bs> :transpose-words]
    [(.. (c :x) (c :t)) :<esc>ddpi :transpose-lines] ; *

    ;; case
    ;; INFO: Actually there is no efficiency difference between abolish.vim's default key map (+ <c-o>) and bellow commands.
    ; [(m :u) "<esc>llbgUwi" :uppercase-word]
    ; [(m :l) "<esc>llbguwi" :lowercase-word]
    ; [(m :c) "<esc>llbvui" :capitalcase-word]

    ;; comment
    [(m ";") "<esc>:execute \"normal \\<plug>CommentaryLine\"<cr>a"
     "Comment line"]

    ;; copy & paste
    [(c :c) "<c-o>v" "mark the start point of yank"] ; *
    ; [(c :y) "<esc>pa" "paste"] ; *

    ;; undo & redo
    [(c :z) "<esc>ui" "undo"] ; *
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
