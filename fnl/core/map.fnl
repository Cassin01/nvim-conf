(local {: map* : map : map-f} (require :kaza.map))
(local {:string s} (require :util.src))

;;; show glow
(map* "n" "<space>w" ":Glow<cr>" {:silent true :noremap true :nowait true})

;;; show `message` to new buff
(map-f :<space>m
       (lambda []
         (let  [buf (vim.api.nvim_create_buf false true)]
           (vim.api.nvim_buf_set_lines buf 0 100 false (s.split (vim.api.nvim_exec "messages" true ) "\n"))
           (local height (vim.api.nvim_buf_line_count buf))
           (vim.api.nvim_open_win buf true {:relative :editor :style :minimal :row 3 :col 3 :height 10 :width 40})))
       "show_message")

;;; insert mode
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
(map :i "∂" "<Del>" "<opt-d>: Delete (delete a char at the back of cursor)")
(map :i "˙" "<c-h>" "<opt-h>: backspace (delete a char at the front of cursor)")
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
