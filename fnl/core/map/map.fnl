(local {: prefix} (require :kaza.map))
(import-macros {: la} :kaza.macros)

[
 [:n :# :*:%s/<C-r>///g<Left><Left> "replace current word"]
 [:t :<esc> :<C-\><C-n> "end insert mode"]
 [:x :<space>ds ::s/\%V\s//g<cr><cmd>noh<cr> "delete spaces"]
 [:x :<c-j> "m'>+1<cr>gv=gv" "moves selected lines down"]
 [:x :<c-k> "m'<-2<cr>gv=gv" "moves selected lines up"]
]
