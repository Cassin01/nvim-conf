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


 [:n :sj :<C-w>j "j"]
 [:n :sk :<C-w>k "k"]
 [:n :sl :<C-w>l "l"]
 [:n :sh :<C-w>h "h"]
 [:n :sJ :<C-w>J "J"]
 [:n :sK :<C-w>K "K"]
 [:n :sL :<C-w>L "L"]
 [:n :sH :<C-w>H "H"]
 [:n :sn :gt "tab next"]
 [:n :sp :gT "tab previous"]
 [:n :sN "<C-u>tabmove +1<CR>" "move tab up"]
 [:n :sP "<C-u>tabmove -1<CR>" "move tab down"]
 [:n :st ::<C-u>tabnew<CR> "tab new"]
 [:n :sT ":<C-u>Unite tab<CR>" "show tab"]
 [:n :ss ::<C-u>sp<CR> "split-horizontally"]
 [:n :sv ::<C-u>vs<CR> "split-vertically"]
 [:n :sq ::<C-u>q<CR> "quit"]
 [:n :sd ::<C-u>bd<CR> "delete tab"]
 [:n "s;" ":<c-u>sp<cr><c-w>J:<c-u>res 10<cr>:<C-u>terminal<cr>:<c-u>setlocal noequalalways<cr>i" "vscode like terminal"]

 ;; quotation completion
[:i "\"" "\"\"<left>" "quotation completion"]
[:i "'" "''<left>" "quotation completion"]

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
