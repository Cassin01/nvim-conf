; core/init.fnlから呼ばれる場合
;(local fennel (require :fennel))
;
;(fn my-searcher [module-name]
;  (let [filename (.. "/Users/cassin/.config/nvim/fnl/core" module-name ".fnl" )]
;    (match (fennel.find-in-archive filename)
;      code (values (partial fennel.eval code {:env :_COMPILER})
;                   filename))))
;(table.insert fennel.macro-searchers my-searcher)
;
;(import-macros
;  {:set-option se-
;   :let-global let-g} :embedded)

(import-macros
  {:set-option se-
   :let-global let-g} :nvim.embedded)

(import-macros
  {: def-augroup : def-autocmd-fn } :zest.macros)

(locaal {: augroup : autocmd } :nvim.embedded)

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
(se- startofline true)
(se- spelllang "en,cjk")
(se- ignorecase true)
; (se- guifont "Hack Nerd Font:h12")
(se- guifont "HackGen:h12")
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
