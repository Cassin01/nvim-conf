(local {:nvim_add_user_command add_user_command} vim.api)

(macro u-cmd [name f]
  `(add_user_command ,name (λ [] ,f) {:force true}))

;;; INFO
;;; require: goyo, limelight
(u-cmd
  :ConcentrateText
    (if _G.__kaza.v.concentrate
      (do
        (when _G.__kaza.v.scrolloff-backup
          (tset vim.o :scrolloff _G.__kaza.v.scrolloff-backup))
        (vim.cmd :Goyo)
        (vim.cmd :Limelight!!)
        (set _G.__kaza.v.concentrate false))
      (do
        (vim.cmd "Goyo")
        (vim.cmd :Limelight!!)
        (tset _G.__kaza.v :scrolloff-backup vim.o.scrolloff)
        (set vim.o.scrolloff 99)
        (set _G.__kaza.v.concentrate true))))

(u-cmd
  :ConcentrateCode
    (if _G.__kaza.v.concentrate-code
      (do
        ; off
        (vim.cmd :SymbolsOutlineClose)
        (vim.cmd :UndotreeHide)
        (vim.cmd :Limelight!!)
        (set _G.__kaza.v.concentrate-code false))
      (do
        ; on
        (vim.cmd :SymbolsOutlineOpen)
        (vim.cmd :UndotreeShow)
        (vim.cmd :Limelight!!)
        (set _G.__kaza.v.concentrate-code true))))
