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

(fn _guard_cursor_position [win]
  "WARN: must be cursor is given"
  (lambda [line col]
    (values
      (if
        (< line 1) 1
        (> line (vf.line :$ win)) (vf.line :$ win)
        line)
      (if
        (< col 0) 0
        (> col (vf.col :$)) (vf.col :$)
        col))))

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
                    g (_guard_cursor_position (va.nvim_get_current_win))]
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
(fn _win-open [row]
  (let [buf (va.nvim_create_buf false true)
        win (va.nvim_open_win buf true {:col 0
                                        :row row
                                        :relative :editor
                                        :anchor :NW
                                        :style :minimal
                                        :height 5
                                        :width vim.o.columns
                                        :focusable false
                                        :border :rounded})]
    (va.nvim_win_set_option win :winblend 20)
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
      (= nr 7)  ; c-g
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

(fn draw-found [find-pos c-win win target-width shift hi-w-summary]
  (var id-cpos nil)
  (each [l ik (ipairs find-pos)]
    (let [i (. ik 1)
          res (. ik 2)]
      (local lnums (fill-spaces
                     (tostring i)
                     (vf.strdisplaywidth
                       (tostring (vf.line :$ c-win)))))
      (add-matches win hi-w-summary l res target-width shift) ; WARN Critical
      (vf.matchaddpos :LineNr [[l 1 shift]] 1 -1 {:window win})
      (push! id-cpos (add-matches c-win :Search i res target-width 0)) ; WARN Critical
      ))
  id-cpos)

(fn _ender [win buf showmode c-win c-ids preview]
  (preview:del)
  (va.nvim_win_close win true)
  (va.nvim_buf_delete buf {:force true})
  (va.nvim_set_option :showmode showmode)
  (del-matches c-ids c-win))

(fn get-first-pos [find-pos pos]
  (if (not= (length find-pos) 0)
    [(. (. find-pos (. pos 1)) 1)
     (- (. (. (. find-pos (. pos 1)) 2) 1) 1) ]
    nil))

(fn guard_cursor_position [win]
  "WARN: must be cursor is given"
  (lambda [line col]
    (local l
      (if
        (< line 1) 1
        (> line (vf.line :$ win)) (vf.line :$ win)
        line))
    (va.nvim_win_set_cursor win [l 0])
    (values
      l
      (if
        (< col 0) 0
        (> col (vf.col :$)) (vf.col :$)
        col))))

(local Preview {:new (fn [self c-buf c-win]
                       (let [(buf win) (_win-open (- vim.o.lines 15))]
                         (tset self :buf buf)
                         (tset self :win win))
                       (va.nvim_buf_set_option self.buf
                                               :filetype
                                               (va.nvim_buf_get_option
                                                 c-buf
                                                 :filetype))
                       (va.nvim_buf_set_lines 
                         self.buf 
                         0 -1 true
                         (va.nvim_buf_get_lines c-buf 0 (vf.line :$ c-win) true))
                       (va.nvim_win_set_option self.win :scrolloff 999)
                       (va.nvim_win_set_option self.win :foldenable false)
                       (va.nvim_win_set_option self.win :number true)
                       self)
                :update (fn [self find-pos pos target-width hi]
                          (vf.clearmatches self.win)
                          (let [pos (get-first-pos find-pos pos)]
                            (unless (= pos nil)
                              (va.nvim_win_set_cursor self.win pos)
                              (_hi-cpos hi self.win pos target-width)))
                          (each [_ [i res] (ipairs find-pos)]
                            (add-matches self.win :Search i res target-width 0)))
                :del (fn [self]
                       (va.nvim_win_close self.win true)
                       (va.nvim_buf_delete self.buf {:force true}))
                :buf nil
                :win nil})

(local inc-search
  (λ []
    (local c-buf (va.nvim_get_current_buf))
    (local c-win (va.nvim_get_current_win))
    (local lines (va.nvim_buf_get_lines c-buf 0 (vf.line :$ c-win) true))
    (local c-pos (va.nvim_win_get_cursor c-win))
    (local (buf win) (_win-open (- vim.o.lines 5)))
    (va.nvim_win_set_option win :scrolloff 999)

    (local preview (Preview:new c-buf c-win))

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

          (set pos [((guard_cursor_position win)  (update-pos nr pos))])
          (va.nvim_win_set_cursor win pos) ; FIXME
          (vf.matchaddpos :PmenuSel [[(. pos 1) 0]] 0 -1 {:window win})

          (local shift (+ (vf.strdisplaywidth (vf.line :$ c-win)) 1))
          (vf.matchaddpos :CursorLineNr [[(. pos 1) 1 shift]] 2 -1 {:window win})

          (set target (if
                        (keys-ignored nr) target
                        (or (= nr 8) (= nr (rt :<Del>))) (string.sub target 1 -2)
                        (.. target (vf.nr2char nr))))
          (local target-width (vf.strdisplaywidth target))

          ;;; Search target on the current buffer.
          (local (find-pos view-lines) (do
                                         (var find-pos [])
                                         (var view-lines [])
                                         (each [i line (ipairs lines)]
                                           (let [kmp-res (gen-res target line)]
                                             (when (not= (length kmp-res) 0)
                                               (table.insert find-pos [i kmp-res])
                                               (let [lnums (fill-spaces (tostring i) (vf.strdisplaywidth (tostring (vf.line :$ c-win))))]
                                                 (table.insert view-lines (.. lnums " " line))))))
                                         (values find-pos view-lines)))
          (va.nvim_buf_set_lines buf 0 -1 true view-lines)

          ;;; view
          (push! id-cpos (draw-found find-pos c-win win target-width shift hi-w-summary))

          (unless (= target-width 0)
            (preview:update find-pos pos target-width hi-c-jump))

          (let [pos (get-first-pos find-pos pos)]
            (unless (= pos nil)
              (push! id-cpos (_hi-cpos hi-c-jump c-win pos target-width))))

          (when (= nr 13) ; cr
            (set done? true)
            (_ender win buf showmode c-win id-cpos preview)
            (let [pos (get-first-pos find-pos pos)]
              (unless (= pos nil)
                (va.nvim_win_set_cursor c-win pos))))

          (when (= nr 27) ; esc
            (set done? true)
            (_ender win buf showmode c-win id-cpos preview)
            (va.nvim_win_set_cursor c-win c-pos))
          (when (= nr 6) ; ctrl-f (focus)
            (unless (= (length find-pos) 0)
              (let [pos [(. (. find-pos (. pos 1)) 1)
                         (- (. (. (. find-pos (. pos 1)) 2) 1) 1)]]
                (va.nvim_win_set_cursor c-win pos)
                (push! id-cpos (_hi-cpos hi-c-jump c-win pos target-width))
                (vim.cmd "normal! zz")
                (push! id-cpos (draw-found find-pos c-win win target-width shift hi-w-summary)))))
          (when (= nr 15) ; ctrl-o (go back to the first position)
            (push! id-cpos (_hi-cpos :Cursor c-win c-pos target-width))
            (va.nvim_win_set_cursor c-win c-pos)
            (vim.cmd "normal! zz")
            (push! id-cpos (draw-found find-pos c-win win target-width shift hi-w-summary)))
          (when (= nr 7) ; ctrl-g
            (unless (= (length find-pos) 0)
            (let [len (length find-pos)
                  num (tonumber (vim.fn.input (.. "1 ~ "  (tostring len) ": ")))]
              (when (and (not= num nil) (<= num len))
                (set pos [((guard_cursor_position win) num (. pos 2))])
                (va.nvim_win_set_cursor win pos) ; FIXME
                (vf.clearmatches win)
                (vf.matchaddpos :CursorLineNr [[(. pos 1) 1 shift]] 2 -1 {:window win})
                (vf.matchaddpos :PmenuSel [[(. pos 1) 0]] 0 -1 {:window win})
                (push! id-cpos (draw-found find-pos c-win win target-width shift hi-w-summary))))))
          (when (= nr (rt "<c-5>")) ; <M-%>
            (set done? true)
            (let [alt (vim.fn.input (.. "Query replace " target " with: "))]
              (_ender win buf showmode c-win id-cpos preview)
              (if (and (not= (length alt) 0) (= (va.nvim_get_current_buf) c-buf))
                (do
                  (vim.cmd (.. "%s/" target "/" alt "/g"))
                  (print "replaced " target " with " alt )))
              (va.nvim_win_set_cursor c-win c-pos)))
          (vim.cmd "redraw!"))))))
;;; }}}

{: goto-line
 : universal-argument
 : inc-search
 : retrive_till_tail
 : retrive_first_half}

