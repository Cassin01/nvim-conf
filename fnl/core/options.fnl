;(import-macros {: se1} :macros.embedded)
(import-macros {
                :set-option se-
                :let-global let-g
                :def-aucmd auc
                :def-autogroup aug} :macros.embedded)

(let-g python2_host_prog "/usr/local/bin/python")
(let-g python3_host_prog "/Users/cassin/.pyenv/shims/python")

(let-g my_color "purify")

(se- fenc "utf-8")
(se- backup false)
(se- swapfile false)
(se- autoread true)
(se- tabstop 4)
(se- shiftwidth 4)
(se- expandtab true)
(se- number true)
(se- scrolloff 10)
(se- cursorline true)
(se- incsearch true)
(se- termguicolors true)
(se- list true)
(se- listchars "tab:»-,trail:□")
(se- spell true)
(se- spelllang "en,cjk")
(se- ignorecase true)

(vim.cmd "hi clear SpellBad")
(vim.cmd "set mouse=a")
(vim.cmd "lang en_US.UTf-8")
(vim.cmd "filetype plugin indent on")
(vim.cmd "set t_8f=^[[38;2;%lu;%lu;%lum")
(vim.cmd "set t_8b=^[[48;2;%lu;%lu;%lum")

(let [cmd (auc ["BufRead"] ["*"] "if line(\"'\\\"\") > 0 && line(\"'\\\"\") <= line(\"$\") | exe \"normal g`\\\"\" | endif") ]
  (aug "vimrcEx" cmd))
