(import-macros {: def : when-let} :util.macros)
(local va vim.api)
(local vf vim.fn)

(def link [name opt] [:string :table :table]
  (let [data (vim.api.nvim_get_hl_by_name name 0)]
    (each [k v (pairs opt)]
      (tset data k v))
    data))

(def gen-hl [name tbl] [:string :table :table]
  [name (link name tbl)])

(def get-hl [name part] [:string :string :?string]
  "name: hlname
  part: bg or fg"
  (let [target (va.nvim_get_hl_by_name name 0)]
    (if
      (= part :fg)
      (.. :# (vf.printf :%0x (. target :foreground)))
      (= part :bg)
      (.. :# (vf.printf :%0x (. target :background)))
      nil)))

(macro add-hl [name tbl]
  `(table.insert hl-info (gen-hl ,name ,tbl)))

(let [hl-info []]
  (add-hl :SpellBad {:fg nil :bg nil :underline true})
  (add-hl :NonText {:underline true})
  (add-hl :SpecialKey {:bg nil :italic true})
  (when-let bg (get-hl :Normal :bg)
    (add-hl :StatusLine {:fg bg})
    (add-hl :StatusLineNC {:fg bg}))
  hl-info)

;;; INFO
; lua print(vim.fn.printf("#%06x", vim.api.nvim_get_hl_by_name("TrailingSpaces", 1).background))
