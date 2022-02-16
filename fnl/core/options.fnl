(import-macros {
                :set-option se-
                :let-global let-g
                } :macros.embedded)

(import-macros
  {: def-augroup : def-autocmd-fn } :zest.macros)

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


(def-augroup :restore-position
  (def-autocmd-fn :BufReadPost "*"
    (when (and (> (vim.fn.line "'\"") 1)
               (<= (vim.fn.line "'\"") (vim.fn.line "$")))
      (vim.cmd "normal! g'\""))))
