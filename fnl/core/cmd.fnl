(import-macros {: la} :kaza.macros)
(local {: concat-with} (require :util.list))
(local {: u-cmd} (require :kaza))

(fn cmd [...]
  (vim.cmd (concat-with " " ...)))

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

;;; TODO: Add completion
(u-cmd
  :H
  (λ [opts]
    (cmd :verbose :help opts.args))
  {:nargs 1})

(u-cmd
  :DoIt
  (λ []
    (local {: async-cmd} (require :kaza.cmd))
    (async-cmd "echo 'hoge'")))

;;; WANR: requires Cassin01/fetch-info
(u-cmd
  :MGInfo
  (λ [opts]
    (local {: async-cmd} (require :kaza.cmd))
    (async-cmd (.. "echom nvim_exec(\'GInfo" opts.args "\', v:true)")))
  {:nargs 1
   :complete (λ [ArgLead CmdLine CursorPos]
               [:F :C :M :W])})

(u-cmd
  :Dearu
  (λ []
    (local subs {"いいます。" "いう。"
                 "します。" "ある。"
                 "なります。" "なる。"
                 "ありません。" "ない。"
                 "りません。" "らない。"
                 "ません。" "ない。"
                 "ました。" "た。"
                 "です。" "である。"
                 "ます。" "る。"})
    (each [k v (pairs subs)]
      (vim.cmd (.. "silent! %s/" k :/ v :/g)))))

(u-cmd
  :ATest
  (λ []
    (local {: async-test} (require :kaza.cmd))
    (async-test)))
