(local {: prefix} (require :kaza.map))

(local h-witch (prefix "<space>w" :h-witch))
(local fugitive (prefix "mg" :fugitive))

[
 [:t :<esc> :<C-\><C-n> "end insert mode"]
 [:v :<space>ds "<cmd>s/ //g<cr>" "delete spaces"]
 [:n :# :*:%s/<C-r>///g<Left><Left> "replace current word"]

 ;; fugitive
 [:n (.. fugitive :g) "<cmd>Git<cr>" "[git] add"]
 [:n (.. fugitive :c) "<cmd>Git commit<cr>" "[git] commit"]
 [:n (.. fugitive :p) "<cmd>Git push<cr>" "[git] push"]

 ;; hyper witch
 [:n (.. h-witch :<space>) "<cmd>NormalWitch SPC<cr>" "[witch] space"]
 [:n (.. h-witch :m) "<cmd>NormalWitch m<cr>" "[witch] m"]
 [:n (.. h-witch ",") "<cmd>NormalWitch ,<cr>" "[witch] ,"]
 [:n (.. h-witch :\) "<cmd>NormalWitch \\<cr>" "[witch] \\"]
 [:n (.. h-witch :s) "<cmd>NormalWitch s<cr>" "[witch] s"]

 ;; quotation completion
[:i "\"" "\"\"<left>" "quotation completion"]
[:i "\"\"" "\"" "quotation completion"]
[:i "'" "''<left>" "quotation completion"]
[:i "''" "'" "quotation completion"]

 ;; move
 [:i "π" "<up>" "<opt-p>: up"]
 [:i "˜" "<down>" "<opt-n>: down"]
 [:i "ƒ" "<right>" "<opt-f>: right"]
 [:i "∫" "<left>" "<opt-b>: left"]
 [:i "´" "<end>" "<opt-e>: jump to EOL"]
 [:i "å" "<C-o>:call To_head_of_line()<CR>" "<opt-a>: jump to BOL"]
 [:i "Ï" "<esc>ea" "<shift><opt-f> move forward one word"]
 [:i "ı" "<esc>bi" "<shift><opt-b> move to one word later"]
 [:i "∆" "<esc>o" "<opt-j> insert new line bellow and jump"]
 [:i "ø" "<esc>O" "<opt-o> insert new line above and jump" ]

 ;; copy & paste
 [:i "˚" "<C-r>=Retrive_till_tail()<CR>" "<opt-k>: delete from cursor to EOL"]
 [:i "∂" "<Del>" "<opt-d>: Delete"]
 [:i "˙" "<c-h>" "<opt-h>: backspace "]
 [:i "€" "<c-o>v" "<opt-@>: mark the start point of yank"]

 ;; undo & redo
 [:v "∑" "y`]i" "<opt-w>: yank"]
 [:v "„" "x`]i" "<opt-w>: delete and yankk"]
 [:i "¥" "<esc>pa" "<opt>y: paste"]
 [:i "—" "<esc>ua" "<opt ->: undo"]
 [:i "±" "<esc><c-r>a" "<opt +>: redo"]
 [:i "≈0" "<c-o><c-w>q" "<opt-x>0: close a window"]
 [:i "≈2" "<c-o>:<c-u>vs<cr>" "<opt-x>2; split-vertically"]
 [:i "≈3" "<c-o>:<c-u>sp<cr>" "<opt-x>3: split-horizontally"]
 [:i "≈o" "<c-o><c-w>w" "<opt-x>o: move to other windows"]

 ;; file
 [:i "≈ß" "<c-o>:w<cr>" "<opt-x><opt-s>: save-file"]
]
