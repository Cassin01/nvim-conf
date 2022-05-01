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

(local vf vim.fn)
(local va vim.api)

(fn split-line-at-point []
    (let [line_text (vf.getline (vf.line :.))
          col (vf.col :.)
          text_after (string.sub line_text col)
          text_before (if (> col 1) (string.sub line_text 1 (- col 1)) "")]
      (values text_before text_after)))

(local retrive_till_tail
  (λ []
    (let [(text_before text_after) (split-line-at-point)]
      (if (= (string.len text_after) 0)
        (vim.cmd "normal! J")
        (vf.setline (vf.line :.) text_before)))))

(local retrive_first_half
  (λ []
    (let [(_ text_after) (split-line-at-point)]
      (var indent_text "")
      (for [i 1 (vf.indent :.)]
        (set indent_text (.. indent_text " ")))
      (vf.setline (vf.line :.) (.. indent_text text_after))
      (vim.cmd "normal! ^"))))

(local goto-line
  (λ []
    (let [cu (vim.fn.win_getid)
          [x y] (vim.api.nvim_win_get_cursor cu)
          n (math.floor (or (tonumber (vim.fn.input "Goto line: "))
                            (error (.. "Could not cast '" (tostring n) "' to number.'"))))
          n (if (> n (vim.fn.line :$)) (vim.fn.line :$) n)
          n (if (< n 1) 1 n)]
      (print (vim.fn.line :$))
      (vim.api.nvim_win_set_cursor cu [n y]))))

(fn guard_cursor_position [line col]
  (values
    (if
      (< line 1) 1
      (> line (vf.line :$)) (vf.line :$)
      line)
    (if
      (< col 0) 0
      (> col (vf.col :$)) (vf.col :$)
      col)))

(local universal-argument
  (λ []
    (var number? "0")
    (var done? false)
    (while (not done?)
      (let [nr (vf.getchar)]
        (when (vf.getchar true)
          (if (and (>= nr 48) (<= nr 57)) ; nr: 0~9
            (set number? (.. number? (vf.nr2char nr)))
            (do
              (set done? true)
              (let [operator (vf.nr2char nr)
                    times (tonumber number?)
                    g guard_cursor_position]
                (if
                  (= operator "n") (va.nvim_win_set_cursor 0 [(g (+ (vf.line :.) times) (vf.col :.))])
                  (= operator "p") (va.nvim_win_set_cursor 0 [(g (- (vf.line :.) times) (vf.col :.))])
                  (= operator "f") (va.nvim_win_set_cursor 0 [(g (vf.line :.) (+ (vf.col :.) times))])
                  (= operator "b") (va.nvim_win_set_cursor 0 [(g (vf.line :.) (- (vf.col :.) times))])
                  (print "operator not matched"))))))))))

[
;; move
[:i (c :b) :<left> "Left"]
[:i (c :f) :<right> "Right"]
[:i (c :a) :<c-o>^ "Jump to BOL"] ; *
[:i (c :\ :a) (c :a) "i_CTRL-A"]
[:i (c :e) :<end> "Jump to EOL"]
[:i (c :j) :<esc>o "<C-j> insert new line bellow and jump"]
[:i (c :o) :<esc>O "<C-o> insert new line above and jump"] ; *
[:i (c :\ :o) (c :o) "i_CTRL-O"]
[:i (m :g :g) goto-line "Goto line"]
[:i (c :u) universal-argument :universal-argument] ; *
[:i (c :\ :u) (c :u) "i_CTRL-U"]
[:i (c :p) :<up> "Up"]
[:i (c :n) :<down> "Down"]
[:i (m :f) :<s-right> "Right"]
[:i (m :b) :<s-left> "Left"]
[:i (m :<) :<esc>ggi "Beginning of buffer"]
[:i (m :>) :<esc>Gi "End of buffer"]

;; edit
[:i (c :d) :<Del> "Delete"] ; * ; <- I actually use default i_CTRl-D.
[:i (c :\ :d) (c :d) "i_CTRl-D"]
[:i (m :h) :<esc>vbc "Delete previous word"]
[:i (m :d) :<esc>wvec "Delete next word"]
[:i (c :k) retrive_till_tail "delete from cursor to EOL"] ; *
[:i (c :\ :k) (c :k) "i_CTRl-K"]
[:i (c-s :k) retrive_first_half "delete from cursor to BOL"]

;; copy & paste
[:i (c "@") "<c-o>v" "mark the start point of yank"]
[:i (c :y) "<esc>pa" "paste"] ; *
[:i (c :\ :y) (c :y) "i_CTRl-Y"]

;; undo & redo
[:i (c :-) "<esc>ua" "undo"]
[:i (c :+) "<esc><c-r>a" "redo"]

;; window
[:i (c :x :0) "<c-o><c-w>q" "Close a window"]
[:i (c :x :1) "<c-o>:<c-u>only<cr>" "Delete-other-windows"]
[:i (c :x :2) "<c-o>:<c-u>vs<cr>" "Split-vertically"]
[:i (c :x :3) "<c-o>:<c-u>sp<cr>" "Split-horizontally"]
[:i (c :x :o) "<c-o><c-w>w" "Move to other windows"]
[:i (c :x :k) "<c-o>:bdelete<cr>" "Kill buffer"]

;; file
[:i (.. (c :x) (c :s)) "<c-o>:update<cr>" "save-file"]
]
