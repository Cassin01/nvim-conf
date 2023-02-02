(local {: prefix : rt} (require :kaza.map))
(import-macros {: la : cmd} :kaza.macros)

; (local {: inc-search} (require :emacs-key-source))

[
 [:i :<c-g>t "<Plug>(hwitch-tex)" "h-witch tex"]
 [:i :<c-g><c-u> :<esc>gUvbgi "upper case"]
 [:i :<c-g><c-l> :<esc>guvbgi "lower case"]
 [:t :<esc> :<C-\><C-n> "end insert mode"]

 [:x :<space>ds ::s/\%V\s//g<cr><cmd>noh<cr> "delete spaces"]
 [:x :<c-j> "m'>+1<cr>gv=gv" "moves selected lines down"]
 [:x :<c-k> "m'<-2<cr>gv=gv" "moves selected lines up"]
 [:x :< :<gv "deindent"]
 [:x :< :>gv "indent"]

 ; [:n :<c-s-i> "<cmd>echo 'hoge'<cr>" "hge"]
 [:n :# :*:%s/<C-r>///g<Left><Left> "replace current word"]
 [:n :Y :y$ "yank the current line"]
 [:n :U :<C-r> "redo"]
 [:n :<space><c-i> "<cmd>echo 'c-i'<cr>" "for test"]
 [:n :<space><c-u> "<cmd> echom 'c-u'<cr>" "c-u for test"]
 ; [:n :<c-s> inc-search "incremental search"]

 [:n :sh :0 "line start"]
 [:n :sl :$ "line end"]
 [:n :ss :^ "first non-blank in line"]
 [:n :se :G "last line"]
 [:n :sg :gg "file start"]
 [:n :st :H "window top"]
 [:n :sc :M "window center"]
 [:n :sb :L "window bottom"]
 [:n :sn :<cmd>bnext<cr> "next buffer"]
 [:n :sp :<cmd>bprev<cr>"previous buffer"]
 [:n :sd :gd "difinition"]
 [:n :sm :% "match"]
 [:n :sj "<Plug>(leap-forward-to)" "leap forward"]
 [:n :sk "<Plug>(leap-backward-to)" "leap backward"]
 [:n :syf "<cmd>let @+=expand('%')<CR>" "yank current file name"]
]
