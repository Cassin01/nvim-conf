(local indent 4)
{:fenc :utf-8
 :backup false
 :swapfile false
 :autoread true
 :shiftwidth indent
 :tabstop indent
 :softtabstop indent
 :expandtab true
 :autoindent true ; default on
 ;; :cmdheight 0
 :number true
 :relativenumber true
 ; :winbar :%f
 ; :winbar "%{%v:lua.require'lua.winbar'.eval()%}"
 :pumheight 10
 :scrolloff 10
 :cursorline true
 :incsearch true
 :termguicolors true
 :splitkeep :screen ; :topline
 :background :dark
 :mouse :a
;; :t_8f "^[[38;2;%lu;%lu;%lum"
;; :t_8b "^[[48;2;%lu;%lu;%lum"
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
 :ruler false
 :wrapmargin 2 ; Number of characters from the right window border where wrapping starts.
 :wrap false
 :history 1000
 ; :ttimeout false ; default on
 ; :ttimeoutlen 0
 :timeout true
 :timeoutlen 1000
 :confirm true
 ; :lazyredraw true ; WARN: In trial
 }
