(local {: map : map-f : prefix} (require :kaza.map))
(local {:string s} (require :util.src))

;;; normal mode

(vim.api.nvim_set_keymap :n :<space>m ""
       {:callback (lambda []
         (let  [buf (vim.api.nvim_create_buf false true)]
           (vim.api.nvim_buf_set_lines buf 0 100 false (s.split (vim.api.nvim_exec "messages" true ) "\n"))
           (local height (vim.api.nvim_buf_line_count buf))
           (vim.api.nvim_open_win buf true {:relative :editor :style :minimal :row 3 :col 3 :height 10 :width 40})))
        :desc "show_message"
        :noremap true
        :silent true})


;; show glow
(map :n "<space>gw" "<cmd>Glow<cr>" "show markdown preview")

;; ddu
(local ddu (prefix ",u" :ddu))
(map :n (.. ddu :m) "<cmd>Ddu mr<cr>" "history")
(map :n (.. ddu :b) "<cmd>Ddu buffer<cr>" "buffer")
(map :n (.. ddu :r) "<cmd>Ddu register<cr>" "register")
(map :n (.. ddu :n) "<cmd>Ddu file -source-param-new -volatile<cr>" "gen new file")
(map :n (.. ddu :f) "<cmd>Ddu file<cr>" "file")

;; nerdtree
(local nerdtree (prefix "<space>n" :nerdtree))
(map :n (.. nerdtree :c) :<cmd>NERDTreeCWD<CR> "nerdtree cwd")
(map :n (.. nerdtree :t) :<cmd>NERDTreeToggle<CR> "nerdtree toggle")
(map :n (.. nerdtree :f) :<cmd>NERDTreeFind<CR> "nerdtree find")

;; telescope
(local telescope (prefix "<space>t" :telescope))
(map :n (.. telescope :f) "<cmd>Telescope find_files<cr>" "find files")
(map :n (.. telescope :g) "<cmd>Telescope live_grep<cr>" "live grep")
(map :n (.. telescope :b) "<cmd>Telescope buffers<cr>" "buffers")
(map :n (.. telescope :h) "<cmd>Telescope help_tags<cr>" "help tags")

(local h-witch (prefix "<space>w" :h-witch))
(map :n (.. h-witch :<space>) "<cmd>NormalWitch SPC<cr>" "witch space")
(map :n (.. h-witch :m) "<cmd>NormalWitch m<cr>" "witch m")
(map :n (.. h-witch ",") "<cmd>NormalWitch ,<cr>" "witch ,")
(map :n (.. h-witch :\) "<cmd>NormalWitch \\<cr>" "witch \\")


;;; insert mode

;; move
(map :i "π" "<up>" "<opt-p>: up")
(map :i "˜" "<down>" "<opt-n>: down")
(map :i "ƒ" "<right>" "<opt-f>: right")
(map :i "∫" "<left>" "<opt-b>: left")
(map :i "´" "<end>" "<opt-e>: jump to EOL")
(map :i "å" "<C-o>:call To_head_of_line()<CR>" "<opt-a>: jump to BOL")
(map :i "Ï" "<esc>ea" "<shift><opt-f> move forward one word")
(map :i "ı" "<esc>bi" "<shift><opt-b> move to one word later")
(map :i "∆" "<esc>o" "<opt-j> insert new line bellow and jump")
(map :i "ø" "<esc>O" "<opt-o> insert new line above and jump" )

;; copy & paste
(map :i "˚" "<C-r>=Retrive_till_tail()<CR>" "<opt-k>: delete from cursor to EOL")
(map :i "∂" "<Del>" "<opt-d>: Delete")
(map :i "˙" "<c-h>" "<opt-h>: backspace ")
(map :i "€" "<c-o>v" "<opt-@>: mark the start point of yank")
(map :v "∑" "y`]i" "<opt-w>: yank")
(map :v "„" "x`]i" "<opt-w>: delete and yankk")
(map :i "¥" "<esc>pa" "<opt>y: paste")

;; undo & redo
(map :i "—" "<esc>ua" "<opt-->: undo")
(map :i "±" "<esc><c-r>a" "<opt-+>: redo")

;; window
(map :i "≈0" "<c-o><c-w>q" "<opt-x>0: close a window")
(map :i "≈2" "<c-o>:<c-u>vs<cr>" "<opt-x>2; split-vertically")
(map :i "≈3" "<c-o>:<c-u>sp<cr>" "<opt-x>3: split-horizontally")
(map :i "≈o" "<c-o><c-w>w" "<opt-x>o: move to other windows")

;; file
(map :i "≈ß" "<c-o>:w<cr>" "<opt-x><opt-s>: save-file")

{}
