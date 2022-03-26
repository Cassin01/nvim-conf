(local {: prefix} (require :kaza.map))

(local ddu (prefix ",u" :ddu))
(local nerdtree (prefix "<space>n" :nerdtree))
(local telescope (prefix "<space>t" :telescope))
(local undo-tree (prefix "<space>u" :undo-tree))
(local h-witch (prefix "<space>w" :h-witch))
(local fugitive (prefix "mg" :fugitive))

[
 [:t :<esc> :<C-\><C-n> "end insert mode"]

 ;; glow
 [:n "<space>gw" "<cmd>Glow<cr>" "show markdown preview"]

 ;; ddu
 [:n (.. ddu :m) "<cmd>Ddu mr<cr>" "ddu history"]
 [:n (.. ddu :b) "<cmd>Ddu buffer<cr>" "ddu buffer"]
 [:n (.. ddu :r) "<cmd>Ddu register<cr>" "ddu register"]
 [:n (.. ddu :n) "<cmd>Ddu file -source-param-new -volatile<cr>" "ddu gen new file"]
 [:n (.. ddu :f) "<cmd>Ddu file<cr>" "file"]

 ;; nerdtree
 [:n (.. nerdtree :c) :<cmd>NERDTreeCWD<CR> "nerdtree cwd"]
 [:n (.. nerdtree :t) :<cmd>NERDTreeToggle<CR> "nerdtree toggle"]
 [:n (.. nerdtree :f) :<cmd>NERDTreeFind<CR> "nerdtree find"]

 ;; telesope
 [:n (.. telescope :f) "<cmd>Telescope find_files<cr>" "find files"]
 [:n (.. telescope :g) "<cmd>Telescope live_grep<cr>" "live grep"]
 [:n (.. telescope :b) "<cmd>Telescope buffers<cr>" "buffers"]
 [:n (.. telescope :h) "<cmd>Telescope help_tags<cr>" "help tags"]
 [:n (.. telescope :t) "<cmd>Telescope<cr>" "telescope"]

 ;; undo-tree
 [:n (.. undo-tree :t) :<cmd>UndotreeToggle<cr> "toggle undo-tree"]

 ;; fugitive
 [:n (.. fugitive :g) "<cmd>Git<cr>" "git add"]
 [:n (.. fugitive :c) "<cmd>Git commit<cr>" "git commit"]
 [:n (.. fugitive :p) "<cmd>Git push<cr>" "git push"]

 ;; hyper witch
 [:n (.. h-witch :<space>) "<cmd>NormalWitch SPC<cr>" "witch space"]
 [:n (.. h-witch :m) "<cmd>NormalWitch m<cr>" "witch m"]
 [:n (.. h-witch ",") "<cmd>NormalWitch ,<cr>" "witch ,"]
 [:n (.. h-witch :\) "<cmd>NormalWitch \\<cr>" "witch \\"]

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
