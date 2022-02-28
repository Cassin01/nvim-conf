(import-macros m :core.embedded)

(fn augroup [group ...]
  (let [
        cleara true]
    (vim.cmd (.. "augroup " group))
    (when clear
      (vim.cmd :au!))
    (m.for! cmds [...]
            (m.for! i (?->table cmds)
                    (vim.cmd (.. "autocmd " i))))
    (vim.cmd "augroup END")))

(fn autocmd [group ...]
  (let [clauses [...]]
    (assert (= 0 (fmod (length clauses) 2))
            "expected even number of pattern/cmd pairs")
    (let [autocmds []]
      (for [i 1 (length clauses) 2]
        (let [pattern (. clauses i)
              cmd (. clauses (+ 1 i)) ]
          (M.push! autocmds (: "%s %s %s" :format group pattern cmd))))
      autocmds)))


