(local {: execute-cmd} (require :kaza.file))
(local {: hi-clear} (require :kaza.hi))

(tset vim.g :python3_host_prog (. (execute-cmd "which python") 1))
(tset vim.g :colors_name :tokyonight)

(each [key val (pairs (require :core.opt.opts))]
  (tset vim.o key val))

(hi-clear :SpellBad)
(vim.cmd "lang en_US.UTf-8")
(vim.cmd "filetype plugin indent on")

;; undo
(if (vim.fn.has :persistent_undo)
  (let [target-path (vim.fn.expand "~/.local/share/nvim/undo")]
    (if (not (vim.fn.isdirectory target-path))
      (vim.fn.mkdir target-path :p 0700))
    (tset vim.o :undodir target-path)
    (tset vim.o :undofile true)))
