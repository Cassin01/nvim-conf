(local {: execute-cmd} (require :kaza.file))

(tset vim.g :python3_host_prog (. (execute-cmd "which python") 1))
(tset vim.g :my_color :tokyonight)

(each [key val (pairs (require :core.opt.opts))]
  (tset vim.o key val))

(vim.cmd "hi clear SpellBad")
(vim.cmd "set mouse=a")
(vim.cmd "lang en_US.UTf-8")
(vim.cmd "filetype plugin indent on")
(vim.cmd "set t_8f=^[[38;2;%lu;%lu;%lum")
(vim.cmd "set t_8b=^[[48;2;%lu;%lu;%lum")
