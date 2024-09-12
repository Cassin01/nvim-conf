(import-macros {: ui-ignore-filetype} :kaza.macros)
(local {: in? : foldl} (require :util.list))
(local vf vim.fn)

(macro todo []
  (let [keywords# [:TODO :FIXME :XXX]]
    (.. :\<\ "(" (table.concat keywords# :\|) :\ ")")))

(macro todo-ts []
  (let [keywords# [:NOTE :MARK :OPTION :CHANGED :REVIEW :NB :QUESTION :TEMP :DEBUG :OPTIMIZE :REVIEW]]
    (.. :\<\ "(" (table.concat keywords# :\|) :\ ")")))

(macro todo-ex []
  (let [keywords# [:IDEA :INFO :REFACTOR :DEPRECATED :TASK :UPDATE :EXAMPLE :ERROR :WARN :BROKEN :HACK]]
    (.. :\<\ "(" (table.concat keywords# :\|) :\ ")")))

(macro typo []
   (let [keywords# [:codt :codts]]
    (.. :\ "(" (table.concat keywords# :\|) :\ ")")))

(local fts {:fennel [[:CommentHead ";;;"]
                     [:CommentHead ";;"]
                     [:Error :iparis]
                     [:Error :prinnt]]
           :rust [[:Todo "#"]]
           :go [[:Error :sturct]]})


;;; fold-maker {{{
(fn str2list [str]
  (var list [])
  (var len 0)
  (for [i 1 (string.len str)]
    (set len (+ len 1))
    (tset list i (string.sub str i i)))
  (values list len))

; (fn split [str delim]
;   (let [list (str2list str)]
;     (var ret [])
;     (var tmp "")
;     (for [_ c (ipairs list)]
;       (if (= c delim)
;         (do
;           (table.insert ret tmp)
;           (set tmp ""))
;         (set tmp (.. tmp c))))
;     (when (not= tmp nil)
;       (table.isnert ret tmp))
;     ret))

(fn foldmarker []
  (string.gsub vim.wo.foldmarker "," :\|))
;;; }}}

(fn add-matches []
  (if (in? vim.bo.filetype (ui-ignore-filetype))
    (vim.fn.clearmatches)
    (when (foldl (λ [x y] (and x (not= (. y :group) :TodoEX)))
                 true
                 (vim.fn.getmatches))
      (vf.matchadd :TrailingSpaces :\s\+$)
      (vf.matchadd :Tabs :\t)
      (vf.matchadd :DoubleSpace "　")
      (vf.matchadd :TodoEx (todo-ex))
      (vf.matchadd :TodoEx "@dev")
      (vf.matchadd :Todo (todo))
      (vf.matchadd :TSNote (todo-ts))
      (vf.matchadd :Error (typo))
      (vf.matchadd :FoldMark (foldmarker))
      (each [ft matches (pairs fts)]
        (when (= ft vim.bo.filetype)
          (each [_ m (ipairs matches)]
            (vf.matchadd (unpack m)))))
      (when (= (vim.fn.expand :%f) "todo.md")
        (vf.matchadd :Comment "CREATED: \\d\\d\\d\\d-\\d\\d-\\d\\d")))))

{: add-matches}
