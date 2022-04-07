(import-macros {: def} :util.macros)

(def link [name opt] [:string :table :table]
  (let [data (vim.api.nvim_get_hl_by_name name 0)]
    (each [k v (pairs opt)]
      (tset data k v))
    data))

(def gen-hl [name tbl] [:string :table :table]
  [name (link name tbl)])

(macro add-hl [name tbl]
  `(table.insert hl-info (gen-hl ,name ,tbl)))

(let [hl-info [[:SpellBad {:fg nil :bg nil :underline true}]]]
  (add-hl :NonText {:bg nil :underline true})
  (add-hl :SpecialKey {:bg nil :italic true})
  hl-info)

;;; INFO
; lua print(vim.fn.printf("#%06x", vim.api.nvim_get_hl_by_name("TrailingSpaces", 1).background))
