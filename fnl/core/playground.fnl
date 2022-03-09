(import-macros
  {:set-option se-
   :let-global let-g} :kaza.macros)

(local file (require :kaza.file))
(local util (require :util.src))
(local list util.list)

(local {: nvim_add_user_command } vim.api)

;;; set dashboard randomly
(math.randomseed (os.time))
(local custom_headers
  (list.filter
    (lambda [x] (= (file.get-file-extension x) ".txt"))
    (file.dirlookup (.. (file.nvim-home) "/data/custom_headers") 2)))
(local icon (file.read_lines  (util.list.choice custom_headers)))
(local fortune (file.execute-cmd "fortune"))
(let-g dashboard_custom_header icon)
(let-g dashboard_custom_footer fortune)

; Concentrate mode
(nvim_add_user_command
  :Concentrate
  (lambda []
    (if _G._kaza.v.concentrate
      (do
        (when _G._kaza.v.scrolloff-backup
          (tset vim.o :scrolloff _G._kaza.v.scrolloff-backup))
        (vim.cmd :Goyo)
        (vim.cmd :Limelight!!)
        (vim.cmd "Goyo")
        (set _G._kaza.v.concentrate false))
      (do
        (vim.cmd "Goyo 120")
        (vim.cmd :Limelight!!)
        (tset _G._kaza.v :scrolloff-backup vim.o.scrolloff)
        (set vim.o.scrolloff 99)
        (set _G._kaza.v.concentrate true))))
  {:force true})

