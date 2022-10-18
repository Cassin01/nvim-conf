(local {: prefix : rt} (require :kaza.map))
(import-macros {: la : cmd} :kaza.macros)

(local {: inc-search} (require :emacs-key-source))

[
 [:n :# :*:%s/<C-r>///g<Left><Left> "replace current word"]
 [:t :<esc> :<C-\><C-n> "end insert mode"]
 [:x :<space>ds ::s/\%V\s//g<cr><cmd>noh<cr> "delete spaces"]
 [:x :<c-j> "m'>+1<cr>gv=gv" "moves selected lines down"]
 [:x :<c-k> "m'<-2<cr>gv=gv" "moves selected lines up"]
 ; [:n :<c-s-i> "<cmd>echo 'hoge'<cr>" "hge"]
 [:n :<space><c-i> "<cmd>echo 'c-i'<cr>" "for test"]
 [:n :<space><c-u> "<cmd> echom 'c-u'<cr>" "c-u for test"]
 [:n :<c-s> inc-search "incremental search"]
 [:i :<c-g>t "<Plug>(hwitch-tex)" "h-witch tex"]
]
