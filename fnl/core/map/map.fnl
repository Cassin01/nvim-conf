(local {: prefix} (require :kaza.map))

(local h-witch (prefix "<space>w" :h-witch))
(local fugitive (prefix "mg" :fugitive))

[
 [:n :# :*:%s/<C-r>///g<Left><Left> "replace current word"]
 [:t :<esc> :<C-\><C-n> "end insert mode"]

 [:x :<space>ds ::s/\%V\s//g<cr><cmd>noh<cr> "delete spaces"]
 [:x :<c-j> "m'>+1<cr>gv=gv" "moves selected lines down"]
 [:x :<c-k> "m'<-2<cr>gv=gv" "moves selected lines up"]

 ;; quotation completion
 ;[:i "\"" "\"\"<left>" "quotation completion"]
 ;[:i "'" "''<left>" "quotation completion"]
 ;[:i "''" "'" "quotation completion"]
]
