(local M {})
(local util (require :util.src))
(local list util.list)

;;; get containing path o lua file
(fn M.script-path []
  (let [str (debug.getinfo 2 "S")
        paths (str.source:sub 2)]
    (paths:match "(.*/)")))

(fn M.current-file-name []
  (vim.api.nvim_exec "echo expand('%')" true))

;;; whether if the file exists
(fn M.filereadable [path]
  (local cmd  (.. "echo filereadable(expand(\"" path "\"))"))
  (vim.api.nvim_exec cmd true))

;;; get `~` path
(fn M.home []
  (vim.api.nvim_exec "echo expand(\"$HOME\")" true))

;;; get `~/.config/nvim`
(fn M.nvim-home []
  (local cmd "echo expand(\"$HOME/.config/nvim\")")
  (vim.api.nvim_exec cmd true))

;;; read_all
(fn M.read_file [path]
  (local (file msg) (io.open path "rb"))
  (if (not file)
    nil
    (do
      (local content (file.read file "*all"))
      (file.close file)
      content)))

(fn empty [s]
  (or (= s nil) (= s "")))

;;; read all lines
(fn M.read_lines [path]
  (if (M.filereadable path)
    (do
      (list.unfold-iter #(= nil $1) (lambda [x] (x)) (lambda [x] x) (io.lines path)))
    nil))


;; file only, depth 1
;; find . -maxdepth 1 -type f
(fn M.dirlookup [dir]
  (local p (io.popen (.. "find \"" dir  "\" -maxdepth 1 -type f")))
  (list.unfold-iter #(= nil $1) (lambda [x] (x)) (lambda [x] x) (p.lines p)))

;;; test

(local (method-name file-name) ...)
(when (empty method-name)
  (assert (M.filereadable "/Users/cassin/.config/nvim/init.lua") "test failed")
  ;(print (M.filereadable "/Users/cassin/.config/nvim/init.lua"))
  ; (local path (.. (M.nvim-home) "/fnl/nvim/hoge.txt"))
  ; (print (M.filereadable path))
  ; (list.dump (M.read_lines path))
  (list.dump (M.dirlookup "/Users/cassin/.config/nvim"))

  ; (local it (io.lines path))
  ; (print (it))
  ; (print (it))
  ; (print (= nil (it)))
  )

M
;(print (M.nvim-home))
