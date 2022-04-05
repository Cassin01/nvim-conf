(local {: find : foldl} (require :util.src.list))

(local todo_ignore_filetype [:dashboard :help :nerdtree :telescopePrompt ""])
(local keywords [:IDEA :INFO :REFACTOR :DEPRECATED :TASK :UPDATE :EXAMPLE :ERROR :WARN :BROKEN])
(local todo_regex (.. :\<\ "(" (table.concat keywords :\|) :\ ")"))
(local hl-data [[:Tabs {:bg :#eeeeec}]
                [:TrailingSpaces {:bg :#FF0000}]
                [:DoubleSpace {:bg :#FF0682}]
                [:TodoEx {:bg :#c4a005}]])

(fn add-matchs []
  (if (find vim.bo.filetype todo_ignore_filetype)
    (vim.fn.clearmatches)
    (when (foldl (λ [x y] (and x (not= (y :group) :TodoEX))) 
                 true 
                 (vim.fn.getmatches))
      (vim.fn.matchadd :TrailingSpaces :\s\+$)
      (vim.fn.matchadd :Tabs :\t)
      (vim.fn.matchadd :ZenkakuSpace "　")
      (vim.fn.matchadd :TodoEx todo_regex))))

{: add-matchs}
