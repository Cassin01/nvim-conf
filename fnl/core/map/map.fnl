(local {: prefix} (require :kaza.map))

(local h-witch (prefix "<space>w" :h-witch))
(local fugitive (prefix "mg" :fugitive))

[
 [:t :<esc> :<C-\><C-n> "end insert mode"]
 [:x :<space>ds ::s/\%V\s//g<cr><cmd>noh<cr> "delete spaces"]
 [:n :# :*:%s/<C-r>///g<Left><Left> "replace current word"]

 ;; quotation completion
 ;[:i "\"" "\"\"<left>" "quotation completion"]
 ;[:i "'" "''<left>" "quotation completion"]
 ;[:i "''" "'" "quotation completion"]
]
