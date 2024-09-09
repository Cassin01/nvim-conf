(local {: prefix : rt} (require :kaza.map))
(import-macros {: la : cmd} :kaza.macros)

; (local {: inc-search} (require :emacs-key-source))

[
 [:i :<c-g>t "<Plug>(hwitch-tex)" "h-witch tex"]
 [:i :<c-g><c-u> :<esc>gUvbgi "upper case"]
 [:i :<c-g><c-l> :<esc>guvbgi "lower case"]
 [:i :<left> :<c-g>U<left> "left"]
 [:i :<right> :<c-g>U<right> "right"]
 [:t :<esc> :<C-\><C-n> "end insert mode"]

 [:x :<space>ds ::s/\%V\s//g<cr><cmd>noh<cr> "delete spaces"]
 [:x :<c-j> "m'>+1<cr>gv=gv" "moves selected lines down"]
 [:x :<c-k> "m'<-2<cr>gv=gv" "moves selected lines up"]
 ; [:x :< :<gv "deindent"]
 ; [:x :< :>gv "indent"]

 ; [:n :<c-s-i> "<cmd>echo 'hoge'<cr>" "hge"]
 [:n :# :*:%s/<C-r>///g<Left><Left> "replace current word"]
 [:n :Y :y$ "yank the current line"]
 [:n :U :<C-r> "redo"]
 [:n :<space><c-i> "<cmd>echo 'c-i'<cr>" "for test"]
 [:n :<space><c-u> "<cmd> echom 'c-u'<cr>" "c-u for test"]
 [:n :<F7> "<cmd>!make<cr>" "make"]
 ; [:n :<c-s> inc-search "incremental search"]

 [[:n :v] :sh :0 "line start"]
 [[:n :v] :sl :$ "line end"]
 [[:n :v] :ss :^ "first non-blank in line"]
 [[:n :v] :sw :^w "second non-blank in line"]
 [[:n :v] :se :G "last line"]
 [[:n :v] :sg :gg "file start"]
 [[:n :v] :st :H "window top"]
 [[:n :v] :sc :M "window center"]
 [[:n :v] :sb :L "window bottom"]
 [[:n :v] :sn :<cmd>bnext<cr> "next buffer"]
 [[:n :v] :sp :<cmd>bprev<cr>"previous buffer"]
 [[:n :v] :sd :gd "difinition"]
 [[:n :v] :sm :% "match"]
 [[:n :v] :sj "<Plug>(leap-forward-to)" "leap forward"]
 [[:n :v] :sk "<Plug>(leap-backward-to)" "leap backward"]
 [[:n :v] :syf "<cmd>let @+=expand('%')<CR>" "yank current file name"]
]
