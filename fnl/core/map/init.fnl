(local {: map : prefix-o} (require :kaza.map))
(local {:string s} (require :util.src))

(macro cmd [s] (string.format "<cmd>%s<cr>" s))

(macro nmaps [prefix desc tbl]
  `(let [prefix# (prefix-o :n ,prefix ,desc)]
     (each [_# l# (ipairs ,tbl)]
       (prefix#.map (unpack l#)))))

(nmaps :<space>c :packer [[:c (cmd :PackerCompile) :compile]
                          [:i (cmd :PackerInstall) :install]
                          [:sy (cmd :PackerSync) :sync]
                          [:st (cmd :PackerStatus) :status]])

;(map :n :<space> "<cmd>NormalWitch SPC<cr>" "wich")
(let [prefix (prefix-o :n :<space>w :wich)]
  (prefix.map :<space> "<cmd>NormalWitch SPC<cr>" :space)
  (prefix.map :\ "<cmd>NormalWitch \\<cr>" :\)
  (prefix.map :b "<Plug>(hwhich-bookmark)" "book mark")
  (prefix.map :n "<Plug>(hwhich-normal)" "normal wich")
  (prefix.map :u "<Plug>(hwich-ultisnips)" "ultisnips")
  (prefix.map :t "<Plug>(hwich-tex)" "tex")
  (prefix.map :r "<cmd>REGWITCH<cr>" "register")
  (prefix.map :e "<cmd>KeyWindow<cr>" "evil"))

(let [prefix (prefix-o :n :<space>s :win)]
  (prefix.map :j :<C-w>j "j")
  (prefix.map :k :<C-w>k "k")
  (prefix.map :l :<C-w>l "l")
  (prefix.map :h :<C-w>h "h")
  (prefix.map :J :<C-w>J "J")
  (prefix.map :K :<C-w>K "K")
  (prefix.map :L :<C-w>L "L")
  (prefix.map :H :<C-w>H "H")
  (prefix.map :n :gt "tab next")
  (prefix.map :p :gT "tab previous")
  (prefix.map :N (cmd "tabmove +1") "move tab up")
  (prefix.map :P (cmd "tabmove -1") "move tab down")
  (prefix.map :t ::<C-u>tabnew<CR> "tab new")
  (prefix.map :T ":<C-u>Unite tab<CR>" "show tab")
  (prefix.map :o (cmd :only) "only (close all windows(splits) except the current one)")
  (prefix.map :s (cmd :sp) "split-horizontally")
  (prefix.map :v (cmd :vs) "split-vertically")
  (prefix.map :q (cmd :q) "quit")
  (prefix.map :d (cmd :bd) "delete tab")
  (prefix.map ";" ":<c-u>sp<cr><c-w>J:<c-u>res 10<cr>:<C-u>terminal<cr>:<c-u>setlocal noequalalways<cr>i" "vscode like terminal"))

(let [prefix (prefix-o :n :<space>m :me)]
  (prefix.map :nh :<cmd>noh<cr> "turn off search highlighting until the next search")
  (prefix.map :sd "<cmd>sp<cr><cmd>edit %:h<tab><cr>" "show current directory")
  (prefix.map :sf "<cmd>source %<cr>" "source a current file")
  (prefix.map :pc "<cmd>Unite colorscheme -auto-preview<cr>" "preview colorschemes")
  (prefix.map :rs ::%s/\s\+$//ge<cr> "remove trailing spaces")
  (prefix.map :a ":vim TODO ~/org/*.org<cr>" "agenda")
  (prefix.map :ts ":%s/\t/ /g<cr>" "replace tab with space")
  (prefix.map :cd ":<c-u>lcd %:p:h<cr>" "move current directory to here")
  (prefix.map "]f" ":<c-u>set clipboard+=unnamed<cr>" "enable clipboard")
  (prefix.map "[f" ":<c-u>set clipboard-=unnamed<cr>" "disable clipboard")
  (prefix.map "]x" ":<c-u>setlocal conceallevel=1<cr>" "hide conceal")
  (prefix.map "[x" ":<c-u>setlocal conceallevel=0<cr>" "show conceal")
  (prefix.map-f :fn (λ [] (print (vim.fn.expand :%:t))) "show file name")
  (prefix.map-f :fp (λ [] (print (vim.fn.expand :%:p))) "show file path")
  (prefix.map-f :ft (λ [] (if (= vim.o.foldmethod :indent)
                               (tset vim.o :foldmethod :marker)
                               (tset vim.o :foldmethod :indent))
                              (print (.. "foldmethod is now " vim.o.foldmethod))) "toggle foldmethod")
  (prefix.map-f :lm (λ [] (local {: cursor : strlen : getline} vim.fn)
                         (cursor 0 (/ (strlen (getline :.)) 2))) "go middle of a line")
  (prefix.map-f :m (λ [] (let  [buf (vim.api.nvim_create_buf false true)]
                              (vim.api.nvim_buf_set_lines buf 0 100 false (s.split (vim.api.nvim_exec "messages" true ) "\n"))
                              (local height (vim.api.nvim_buf_line_count buf))
                              (vim.api.nvim_open_win buf true {:relative :editor :style :minimal :row 3 :col 3 :height 40 :width 150})))
                "show message")
  (when (vim.fn.has :mac)
    (prefix.map :? "<cmd>!open dict://<cword><cr>" "mac dictionary")
    (each [_ k (ipairs (require :core.map.mac))]
      (map (unpack k)))))

(each [_ k (ipairs (require :core.map.map))]
  (map (unpack k)))

((-> :core.map.bracket require (. :setup)))

{}
