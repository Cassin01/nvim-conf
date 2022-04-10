;; INFO
;lua print(vim.fn.printf("#%06x", vim.api.nvim_get_hl_by_name("TrailingSpaces", 1).background))

(local {: in? : foldl} (require :util.list))
(import-macros {: ui-ignore-filetype} :kaza.macros)

(macro todo_regex []
  (let [keywords# [:IDEA :INFO :REFACTOR :DEPRECATED :TASK :UPDATE :EXAMPLE :ERROR :WARN :BROKEN]]
    (.. :\<\ "(" (table.concat keywords# :\|) :\ ")")))

(fn add-matchs []
  (if (in? vim.bo.filetype (ui-ignore-filetype))
    (vim.fn.clearmatches)
    (when (foldl (λ [x y] (and x (not= (. y :group) :TodoEX)))
                 true
                 (vim.fn.getmatches))
      (vim.fn.matchadd :TrailingSpaces :\s\+$)
      (vim.fn.matchadd :Tabs :\t)
      (vim.fn.matchadd :DoubleSpace "　")
      (vim.fn.matchadd :TodoEx (todo_regex)))))

{: add-matchs}
