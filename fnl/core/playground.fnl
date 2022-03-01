(import-macros
  {:set-option se-
   :let-global let-g} :kaza.macros)

(local file (require :kaza.file))
(local util (require :util.src))
(local list util.list)


;;; set dashboard randomly
(math.randomseed (os.time))
(local custom_headers
  (list.filter
    (lambda [x] (= (file.get-file-extension x) ".txt"))
    (file.dirlookup (.. (file.nvim-home) "/data/custom_headers") 1)))
(local icon (file.read_lines  (util.list.choice custom_headers)))
(local fortune (file.execute-cmd "fortune"))
(let-g dashboard_custom_header icon)
(let-g dashboard_custom_footer fortune)
