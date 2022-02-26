(import-macros
  {:set-option se-
   :let-global let-g} :core.embedded)

(local file (require :nvim.file))
(local util (require :util.src))


;;; set dashboard randomly
(math.randomseed (os.time))
(local custom_headers (file.dirlookup (.. (file.nvim-home) "/data/custom_headers") 1))
(local hoge (file.read_lines  (util.list.choice custom_headers)))
(let-g dashboard_custom_header hoge)
