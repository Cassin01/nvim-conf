(local {: kmp} (require :core.map.veil.kmp))
(macro unless [cond ...]
  `(when (not ,cond) ,...))
(local vf vim.fn)
(local va vim.api)

;;; util {{{
(fn concat-with [d ...]
  (table.concat [...] d))
(fn rt [str]
  "replace termcode"
  (va.nvim_replace_termcodes str true true true))
(fn echo [str]
  (va.nvim_echo [[str]] false {}))
;;; }}}

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
                            (do (echo (.. "Could not cast '" (tostring n) "' to number.'")) x)))
          n (if (> n (vim.fn.line :$)) (vim.fn.line :$) n)
          n (if (< n 1) 1 n)]
      (echo (tostring (vim.fn.line $)))
      (vim.api.nvim_win_set_cursor cu [n y]))))

;;; Ctrl-u {{{

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
                  (= nr 106) (va.nvim_win_set_cursor 0 [(g (+ (vf.line :.) times) (vf.col :.))])
                  (= nr 107) (va.nvim_win_set_cursor 0 [(g (- (vf.line :.) times) (vf.col :.))])
                  (= nr 108) (va.nvim_win_set_cursor 0 [(g (vf.line :.) (+ (vf.col :.) times))])
                  (= nr 104) (va.nvim_win_set_cursor 0 [(g (vf.line :.) (- (vf.col :.) times))])
                  (= nr 14) (va.nvim_win_set_cursor 0 [(g (+ (vf.line :.) times) (vf.col :.))])
                  (= nr 16) (va.nvim_win_set_cursor 0 [(g (- (vf.line :.) times) (vf.col :.))])
                  (= nr 6) (va.nvim_win_set_cursor 0 [(g (vf.line :.) (+ (vf.col :.) times))])
                  (= nr 2) (va.nvim_win_set_cursor 0 [(g (vf.line :.) (- (vf.col :.) times))])
                  (echo "operator not matched"))))))))))
;;; }}}

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

(fn add-matches [win group line-num kmp-res width shift]
  (let [wininfo (. (vf.getwininfo win) 1)
        topline (. wininfo :topline)
        botline (. wininfo :botline)]
    ; We can enhance drawing time with restrict drawing regions.
     (if (and (>= line-num topline) (<= line-num botline))
      (do
        (var res [])
        (each [_ col (ipairs kmp-res)]
          (when (> width 0)
            (table.insert res (vf.matchaddpos group [[line-num (+ shift col) width]] 0 -1 {:window win}))))
        res)
       [])))

(fn fill-spaces [str width]
  (let [len (vf.strdisplaywidth str)]
    (if (< len width) (.. (string.rep " " (-> width (- len))) str) str)))

(fn update-pos [nr pos]
  "return pos"
  (if
    (= nr 18) ; c-s
    (values (- (. pos 1) 1) (. pos 2))
    (= nr 19) ; c-r
    (values (+ (. pos 1) 1) (. pos 2))
    (values (. pos 1) (. pos 2))))

(fn keys-ignored [nr]
  (or (= nr 18) ; c-r
      (= nr 19) ; c-s
      (= nr 15) ; c-o
      (= nr 13) ; c-m <cr>
      (= nr 6)  ; c-f
      (= nr (rt :<c-5>))))

(fn gen-res [target line]
  (if (= target "")
    []
    (kmp target line)))

(fn match-exist [win id]
  (var ret false)
  (let [list (vf.getmatches win)]
    (each [_ v (ipairs list)]
      (when (= (. v :id) id)
        (set ret true))))
  ret)

(fn marge [a b]
  (if
    (= nil b) a
    (= (type b) :table) (do (each [_ v (ipairs b)]
                              (table.insert a v)) a)
    (do (table.insert a b) a)))
(macro push! [lst elm]
  `(if (= ,lst nil)
     (set ,lst (marge [] ,elm))
     (set ,lst (marge ,lst ,elm))))

(fn _hi-cpos [group win pos width]
  (vf.matchaddpos group [[(. pos 1) (+ (. pos 2) 1) width]] 9 -1 {:window win}))

(fn del-matches [ids win]
  (unless (= ids nil)
    (each [_ id (ipairs ids)]
      ; (when (match-exist win id)
      (vf.matchdelete id win))))

(fn _ender [win buf showmode c-win c-ids]
  (va.nvim_win_close win true)
  (va.nvim_buf_delete buf {:force true})
  (va.nvim_set_option :showmode showmode)
  (del-matches c-ids c-win))

(local inc-search
  (λ []
    (local c-buf (va.nvim_get_current_buf))
    (local lines (va.nvim_buf_get_lines c-buf 0 (vf.line :$) true))
    (local c-win (va.nvim_get_current_win))
    (local c-pos (va.nvim_win_get_cursor c-win))
    (local (buf win) (_win-open))
    (va.nvim_win_set_option win :scrolloff 999)

    ;; prevent flicking on echo
    (local showmode (let [showmode (. vim.o :showmode)]
                      (if (not= showmode nil)
                        showmode
                        true)))
    (tset vim.o :showmode false)

    (local hi-c-jump :IncSearch)
    (local hi-w-summary :Substitute)

    (var pos [0 0])
    (var done? false)
    (var target "")
    (var id-cpos nil) ; list
    (while (not done?)
      ; (echo (.. "line: " (. pos 1) "/" (vf.line :$ win) ", input: " target))
      (echo (.. "input: " target ", line: " (. pos 1) "/" (vf.line :$ win)))
      (when (vf.getchar true)
        (let [nr (vf.getchar)]
          (vf.clearmatches win)
          (unless (= id-cpos nil)
            (del-matches id-cpos c-win)
            (set id-cpos nil))

          (set pos [(guard_cursor_position  (update-pos nr pos))])
          (va.nvim_win_set_cursor win pos)
          (vf.matchaddpos :PmenuSel [[(. pos 1) 0]] 0 -1 {:window win})

          (local shift (+ (vf.strdisplaywidth (vf.line :$ c-win)) 1))
          (vf.matchaddpos :CursorLineNr [[(. pos 1) 1 shift]] 2 -1 {:window win})

          (set target (if
                        (keys-ignored nr) target
                        (or (= nr 8) (= nr (rt :<Del>))) (string.sub target 1 -2)
                        (.. target (vf.nr2char nr))))
          (local target-width (vf.strdisplaywidth target))
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
                (add-matches win hi-w-summary line-num kmp-res target-width shift) ; WARN Critical
                (vf.matchaddpos :LineNr [[line-num 1 shift]] 1 -1 {:window win})
                (push! id-cpos (add-matches c-win :Search i kmp-res target-width 0)) ; WARN Critical
                (table.insert find-pos [i kmp-res])
                (table.insert view-lines (.. lnums " " line)))))
          (va.nvim_buf_set_lines buf 0 -1 true view-lines)


          (unless (= (length find-pos) 0)
            (let [pos [(. (. find-pos (. pos 1)) 1)
                       (- (. (. (. find-pos (. pos 1)) 2) 1) 1)]]
              (push! id-cpos (_hi-cpos hi-c-jump c-win pos target-width))))

          (when (= nr 13) ; cr
            (set done? true)
            (_ender win buf showmode c-win id-cpos)
            (unless (= (length find-pos) 0)
              (va.nvim_win_set_cursor
                c-win [(. (. find-pos (. pos 1)) 1)
                       (- (. (. (. find-pos (. pos 1)) 2) 1) 1)])))
          (when (= nr 27) ; esc
            (set done? true)
            (_ender win buf showmode c-win id-cpos)
            (va.nvim_win_set_cursor c-win c-pos))
          (when (= nr 6) ; ctrl-f (focus)
            (unless (= (length find-pos) 0)
              (let [pos [(. (. find-pos (. pos 1)) 1)
                         (- (. (. (. find-pos (. pos 1)) 2) 1) 1)]]
                (va.nvim_win_set_cursor c-win pos)
                (push! id-cpos (_hi-cpos hi-c-jump c-win pos target-width))
                (vim.cmd "normal! zz"))))
          (when (= nr 15) ; ctrl-o (go back to the first position)
            (let [c-pos-alt [(. c-pos 1) (+ (. c-pos 2) 1)]]
              (push! id-cpos (_hi-cpos :Cursor c-win c-pos target-width)))
            (va.nvim_win_set_cursor c-win c-pos)
            (vim.cmd "normal! zz"))
          (when (= nr (rt "<c-5>")) ; <M-%>
            (set done? true)
            (let [alt (vim.fn.input (.. "Query replace " target " with: "))]
              (_ender win buf showmode c-win id-cpos)
              (if (= (va.nvim_get_current_buf) c-buf)
                (vim.cmd (.. "%s/" target "/" alt "/g")))
              (va.nvim_win_set_cursor c-win c-pos)))
          (vim.cmd "redraw!"))))))
;;; }}}

{: goto-line
 : universal-argument
 : inc-search
 : retrive_till_tail
 : retrive_first_half}

