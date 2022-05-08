(local {: kmp} (require :core.map.veil.kmp))

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


(macro unless [cond body]
  `(if (not ,cond) ,body))

;;; util {{{
(fn concat-with [d ...]
  (table.concat [...] d))
(fn rt [str]
  "replace termcode"
  (vim.api.nvim_replace_termcodes str true true true))
;;; }}}

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
      (when (vf.getchar true)
        (let [nr (vf.getchar)]
          (if (and (>= nr 48) (<= nr 57)) ; nr: 0~9
            (set number? (.. number? (vf.nr2char nr)))
            (do
              (set done? true)
              (let [operator (vf.nr2char nr)
                    times (tonumber number?)
                    g guard_cursor_position]
                (if
                  (= nr 14) (va.nvim_win_set_cursor 0 [(g (+ (vf.line :.) times) (vf.col :.))])
                  (= nr 16) (va.nvim_win_set_cursor 0 [(g (- (vf.line :.) times) (vf.col :.))])
                  (= nr 6) (va.nvim_win_set_cursor 0 [(g (vf.line :.) (+ (vf.col :.) times))])
                  (= nr 2) (va.nvim_win_set_cursor 0 [(g (vf.line :.) (- (vf.col :.) times))])
                  (print "operator not matched"))))))))))

;;; Ctrl-S {{{
(fn _win-open []
  (let [buf (va.nvim_create_buf false true)
        win (va.nvim_open_win buf true {:col 0
                                        :row (- vim.o.lines 5)
                                        :relative :editor
                                        :anchor :NW
                                        :style :minimal
                                        :height 5
                                        :width vim.o.columns
                                        :border :rounded})]
    (va.nvim_win_set_option win :winblend 10)
    (values buf win)))

(fn add-matches [line-num kmp-res width shift]
  (each [_ col (ipairs kmp-res)]
    (when (> width 0)
    (vf.matchaddpos :IncSearch [[line-num (+ shift col) width]]))))

(fn fill-spaces [str width]
  (let [len (vf.strdisplaywidth str)]
    (if (< len width) (.. (string.rep " " (-> width (- len))) str) str)))

; (fn set-virtual-curosr [nr pos]
(fn update-pos [nr pos]
  "return pos"
  (if
    (= nr (rt :<c-s>)) ; c-s
    (values (- (. pos 1) 1) (. pos 2))
    (= nr (rt :<c-r>)) ; c-r
    (values (+ (. pos 1) 1) (. pos 2))
    (values (. pos 1) (. pos 2))))

(fn keys-ignored [nr]
  "c-m 13" ; <cr>
  (or (= nr 18)
      (= nr 19)
      (= nr 13)
      (= nr (rt :<m-%>))))

(fn gen-res [target line]
  (if (= target "")
    []
    (kmp target line)))

(local inc-search
  (λ []
    (local lines (va.nvim_buf_get_lines 0 0 (vf.line :$) true))
    (local c-win (va.nvim_get_current_win))
    (local c-pos (va.nvim_win_get_cursor c-win))
    (local (buf win) (_win-open))
    (tset vim.wo :scrolloff 999)
    (var pos [0 0])
    (var done? false)
    (var target "")
    (while (not done?)
      (when (vf.getchar true)
        (let [nr (vf.getchar)]

          (vf.clearmatches win)

          (set pos [(guard_cursor_position  (update-pos nr pos))])
          (va.nvim_win_set_cursor win pos)
          (vf.matchaddpos :PmenuSel [[(. pos 1) 0]])

          (set target (if
                        (keys-ignored nr) target
                        (= nr 8) (string.sub target 1 -2)
                        (.. target (vf.nr2char nr))))
          (var view-lines [])
          (var find-pos [])
          (var line-num 0)
          (each [i line (ipairs lines)]
            (let [kmp-res (gen-res target line)]
              (when (not= (length kmp-res) 0)
                (set line-num (+ 1 line-num))
                (local lnums (fill-spaces
                               (tostring i)
                               (vf.strdisplaywidth
                                 (tostring (vf.line :$ c-win)))))
                (add-matches line-num kmp-res
                             (vf.strdisplaywidth target)
                             (+ (vf.strdisplaywidth lnums) 1))
                (table.insert find-pos [i kmp-res])
                (table.insert view-lines (.. lnums " " line)))))
          (va.nvim_buf_set_lines buf 0 -1 true view-lines)
          (vim.cmd "redraw!")
          (when (= nr 13)
            (set done? true)
            (va.nvim_win_close win true)
            (va.nvim_buf_delete buf {:force true}))
          (when (= nr (rt "<M-%>")) ; <M-%>
            (set done? true)
            (let [alt (vim.fn.input (.. "Query replace " target " with: "))]
              (va.nvim_win_close win true)
              (va.nvim_buf_delete buf {:force true})
              (vim.cmd (.. "%s/" target "/" alt "/g"))))
          (unless (= (length find-pos) 0)
            (va.nvim_win_set_cursor
              c-win [(. (. find-pos (. pos 1)) 1)
                     (- (. (. (. find-pos (. pos 1)) 2) 1) 1)]))
          (when (= (length find-pos) 0)
            (set done? true)
            (va.nvim_win_close win true)
            (va.nvim_buf_delete buf {:force true})
            (va.nvim_win_set_cursor c-win c-pos))
          (when (= (length find-pos) 1)
            (when (= (length (. (. find-pos 1) 2)) 1)
              (set done? true)
              (va.nvim_win_close win true)
              (va.nvim_buf_delete buf {:force true})
              (vim.api.nvim_win_set_cursor
                c-win [(. (. find-pos 1) 1)
                       (- (. (. (. find-pos 1) 2) 1) 1)]))))))))
;;; }}}

(fn _translate-arg [key cmd desc]
  (if (= (type cmd) :string)
    [0 :i key cmd {:noremap true :silent true :desc desc}]
    [0 :i key "" {:callback cmd :noremap true :silent true :desc desc}]))

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

    ;; file
    [(.. (c :x) (c :s)) "<c-o>:update<cr>" :save-file]
    ]]
  (icollect [_ k (ipairs map-data)]
            (_translate-arg (unpack k))))
