(import-macros {: def} :util.src.macros)
(def link [name opt] [:string :table :table]
  (let [data (vim.api.nvim_get_hl_by_name name 0)]
    (each [k v (pairs opt)]
      (tset data k v)
      (print k)
      ) data))
(def gen-hl [name tbl] [:string :table :table]
  [name (link name tbl)])

(macro add-hl [body]
  `(table.insert hl-info ,body))

(let [hl-info [[:SpellBad {:fg nil :bg nil :underline true}]]]
  (add-hl (gen-hl :NonText {:bg nil :underline true}))
  (add-hl (gen-hl :SpecialKey {:bg nil :italic true}))
  hl-info)

;;; INFO
; lua print(vim.fn.printf("#%06x", vim.api.nvim_get_hl_by_name("TrailingSpaces", 1).background))
