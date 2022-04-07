;; INFO
;lua print(vim.fn.printf("#%06x", vim.api.nvim_get_hl_by_name("TrailingSpaces", 1).background))

(local {: find : foldl} (require :util.src.list))

(local todo_ignore_filetype [:dashboard :help :nerdtree :telescopePrompt ""])
(local keywords [:IDEA :INFO :REFACTOR :DEPRECATED :TASK :UPDATE :EXAMPLE :ERROR :WARN :BROKEN])
(local todo_regex (.. :\<\ "(" (table.concat keywords :\|) :\ ")"))

(fn add-matchs []
  (if (find vim.bo.filetype todo_ignore_filetype)
    (vim.fn.clearmatches)
    (when (foldl (λ [x y] (and x (not= (y :group) :TodoEX)))
                 true
                 (vim.fn.getmatches))
      (vim.fn.matchadd :TrailingSpaces :\s\+$)
      (vim.fn.matchadd :Tabs :\t)
      (vim.fn.matchadd :DoubleSpace "　")
      (vim.fn.matchadd :TodoEx todo_regex))))

{: add-matchs}
