(local {: map : map-f} (require :kaza.map))
(local {:string s} (require :util.src))

;;; show glow
(map "n" "<space>w" ":Glow<cr>" {:silent true :noremap true :nowait true})

;;; show `message` to new buff
(map-f "<space>m"
       (lambda []
         (let  [buf (vim.api.nvim_create_buf false true)]
           (vim.api.nvim_buf_set_lines buf 0 100 false (s.split (vim.api.nvim_exec "messages" true ) "\n"))
           (local height (vim.api.nvim_buf_line_count buf))
           (vim.api.nvim_open_win buf true {:relative :editor :style :minimal :row 3 :col 3 :height 10 :width 40})))
       "show_message")

{}
