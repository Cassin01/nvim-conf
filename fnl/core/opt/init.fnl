(import-macros {: ep : epi : req-f} :util.macros)

(ep key val (require :core.opt.g) (tset vim.g key val))
(ep key val (require :core.opt.opts) (tset vim.o key val))
(epi _ val (require :core.opt.cmd) (vim.cmd val))

(tset (. _G.__kaza :f) :dump (req-f :dump :util.list))

(vim.opt.clipboard:append {:unnamedplus true
                           :unnamed true})
(tset vim.opt :listchars {:tab "▸▹┊"
                          :trail "□"
                          :extends "❯"
                          :precedes "❮"
                          ; :space "⋅"
                          ; :eol "↴"
                          :nbsp :+
                          })

;; undo
(if (vim.fn.has :persistent_undo)
  (let [target-path (vim.fn.expand "~/.local/share/nvim/undo")]
    (if (not (vim.fn.isdirectory target-path))
      (vim.fn.mkdir target-path :p 0700))
    (tset vim.o :undodir target-path)
    (tset vim.o :undofile true)))
