(local util (require :util.src))
(local list util.list)
(import-macros {: fn*} :util.src.macros)

(local M {})

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
      (list.unfold-iter2 #(= nil $1) (lambda [x] (x)) (lambda [x] x) (io.lines path)))
    nil))

;; file only, depth 1
;; find . -maxdepth 1 -type f
(fn M.dirlookup [dir depth]
  "
  file only, depth 1
  find . -maxdepth 1 -type f
  "
  (local p (io.popen (.. "find \"" dir  "\" -maxdepth " depth " -type f")))
  (list.unfold-iter (p.lines p) p (lambda [x] (io.close x))))

(fn M.execute-cmd [cmd]
  "Execute command and return output as list."
  (local p (io.popen cmd))
  (list.unfold-iter (p.lines p) p (lambda [x] (io.close x))))

;; ref: https://codereview.stackexchange.com/questions/90177/get-file-name-with-extension-and-get-only-extension
(fn* M.get-file-name {:url "string"}
    (url.match url "^.+/(.+)$"))

(fn* M.get-file-extension {:url "string"}
     (url.match url "^.+(%..+)$"))


;;; test

(local (method-name file-name) ...)
(when (empty method-name)
  (assert (M.filereadable "/Users/cassin/.config/nvim/init.lua") "test failed")
  ;(print (M.filereadable "/Users/cassin/.config/nvim/init.lua"))
  ; (local path (.. (M.nvim-home) "/fnl/nvim/hoge.txt"))
  ; (print (M.filereadable path))
  ; (list.dump (M.read_lines path))
  (list.dump (M.dirlookup "/Users/cassin/.config/nvim" 1))

  ; (local it (io.lines path))
  ; (print (it))
  ; (print (it))
  ; (print (= nil (it)))
  )

M
;(print (M.nvim-home))

