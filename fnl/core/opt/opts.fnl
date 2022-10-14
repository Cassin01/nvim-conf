(local indent 4)
{:fenc :utf-8
 :backup false
 :swapfile false
 :autoread true
 :tabstop indent
 :shiftwidth indent
 :softtabstop indent
 :expandtab true
 :autoindent true ; default on
 :cmdheight 0
 :number true
 :relativenumber true
 :winbar :%f
 :scrolloff 10
 :cursorline true
 :incsearch true
 :termguicolors true
:splitkeep :screen ; :topline
 :background :dark
 :mouse :a
 :t_8f "^[[38;2;%lu;%lu;%lum"
 :t_8b "^[[48;2;%lu;%lu;%lum"
 :list true
 ; :listchars "tab:»-,trail:□"
 :spell true
 :ignorecase true
 :smartcase true
 :startofline true
 :spelllang "en,cjk"
 :guifont "HackGen Console"
 :inccommand :split
 :equalalways false
 :laststatus 3 ; 0
 ; :ruler false
 :history 1000
 :ttimeout true ; default on
 :ttimeoutlen 100
 :confirm true
 ; :lazyredraw true ; WARN: In trial
 }
