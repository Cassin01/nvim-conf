(import-macros {: la} :kaza.macros)
(local {: u-cmd} (require :kaza))

;;; INFO
;;; require: goyo, limelight
(u-cmd
  :ConcentrateText
    (la (if _G.__kaza.v.concentrate
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
        (set _G.__kaza.v.concentrate true)))))

;;; INFO
;;; require: limeligh, undotree
(u-cmd
  :ConcentrateCode
    (la (if _G.__kaza.v.concentrate-code
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
        (set _G.__kaza.v.concentrate-code true)))))
