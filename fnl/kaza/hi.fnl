(import-macros {: def} :util.macros)
(local {: concat-with} (require :util.string))

(def get-hl [name part] [:string :string :?string]
  "name: hlname
  part: bg or fg"
  (let [target (vim.api.nvim_get_hl_by_name name 0)]
    (if
      (= part :fg)
      (.. :# (vim.fn.printf :%06x (or (. target :foreground) 0)))
      (= part :bg)
      (.. :# (vim.fn.printf :%06x (or (. target :background) 0)))
      nil)))

(fn hi-clear [group-name]
  "clear highlight"
  (assert (-> (type group-name) (= :string)))
  (let [cmd (concat-with " " :hi :clear group-name)]
    (vim.cmd cmd)))

{: hi-clear : get-hl}
