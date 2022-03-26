(local {: execute-cmd} (require :kaza.file))
(local {: hi-clear} (require :kaza.hi))

(each [k v (pairs (require :core.opt.g))]
  (tset vim.g k v))

(each [key val (pairs (require :core.opt.opts))]
  (tset vim.o key val))

(each [_ val (ipairs (require :core.opt.cmd))]
  (vim.cmd val))

(hi-clear :SpellBad)

;; undo
(if (vim.fn.has :persistent_undo)
  (let [target-path (vim.fn.expand "~/.local/share/nvim/undo")]
    (if (not (vim.fn.isdirectory target-path))
      (vim.fn.mkdir target-path :p 0700))
    (tset vim.o :undodir target-path)
    (tset vim.o :undofile true)))
