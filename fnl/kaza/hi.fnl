(local {: concat-with} (require :util.string))

(fn hi-clear [group-name]
  "clear highlight"
  (assert (-> (type group-name) (= :string)))
  (let [cmd (concat-with " " :hi :clear group-name)]
    (vim.cmd cmd)))

{: hi-clear}
