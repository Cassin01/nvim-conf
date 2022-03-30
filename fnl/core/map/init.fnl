(local {: map : prefix-o} (require :kaza.map))
(local {:string s} (require :util.src))

(vim.api.nvim_set_keymap :n :<space>mm ""
       {:callback (lambda []
         (let  [buf (vim.api.nvim_create_buf false true)]
           (vim.api.nvim_buf_set_lines buf 0 100 false (s.split (vim.api.nvim_exec "messages" true ) "\n"))
           (local height (vim.api.nvim_buf_line_count buf))
           (vim.api.nvim_open_win buf true {:relative :editor :style :minimal :row 3 :col 3 :height 40 :width 150})))
        :desc "[me] show_message"
        :noremap true
        :silent true})

(let [prefix (prefix-o :<space>m :me)]
  (prefix.map :n :t "<cmd>sp<cr><cmd>edit %:h<tab><cr>" "show current directory")
  (prefix.map :n :s "<cmd>source %<cr>" "source a current file")
  (prefix.map :n :c "<cmd>Unite colorscheme -auto-preview<cr>" "preview colorschemes")
  (prefix.map :n :rs ::%s/\s\+$//ge<cr> "remove trailing spaces")
  (prefix.map :n :rts ":%s/\t/ /g<cr>" "replace tab with space")
  (prefix.map :n "]f" ":<c-u>set clipboard+=unnamed" "enable clipboard")
  (prefix.map :n "[f" ":<c-u>set clipboard-=unnamed" "disable clipboard")
  (prefix.map :n "]x" "<cmd>setlocal conceallevel=1" "hide conceal")
  (prefix.map :n "[x" "<cmd>setlocal conceallevel=0" "show conceal")
  (prefix.map-f :n :fn (λ [] (print (vim.fn.expand :%:t))) "show file name")
  (prefix.map-f :n :fp (λ [] (print (vim.fn.expand :%:p))) "show file path")
  (prefix.map-f :n :ft (λ [] (if (= vim.o.foldmethod :indent)
                               (tset vim.o :foldmethod :marker)
                               (tset vim.o :foldmethod :indent))
                              (print (.. "foldmethod is now " vim.o.foldmethod))) "toggle foldmethod")
  (prefix.map-f :n :lm (λ []
                         (local {: cursor : strlen : getline} vim.fn)
                         (cursor 0 (/ (strlen (getline :.)) 2))) "go middle of line")

  (when (vim.fn.has :mac)
    (prefix.map :n :? "<cmd>!open dict://<cword><cr>" "mac dictionary")))

(each [_ k (ipairs (require :core.map.map))]
  (map (unpack k)))

((-> :core.map.bracket require (. :setup)))

{}
