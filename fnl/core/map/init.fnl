(import-macros {: epi : req-f : unless} :util.macros)
(import-macros {: la : cmd : plug : space : br : nmaps} :kaza.macros)

(local {: map} (require :kaza.map))

;(map :n :<space> "<cmd>NormalWitch SPC<cr>" "wich")
(nmaps
  (space :w)
  :witch
  [[(space) (cmd "NormalWitch SPC") :space]
   [:\ (cmd "NormalWitch \\") :\]
   [:b (plug "(hwhich-bookmark)") "book mark"]
   [:n (plug "(hwhich-normal)") "normal wich"]
   [:u (plug "(hwich-ultisnips)") "ultisnips"]
   [:t (plug "(hwich-tex)") "tex"]
   [:r (cmd "REGWITCH") :register]
   [:e (cmd "KeyWindow") :evil]])

(nmaps
  (space :s)
  :win
  [[:j :<C-w>j "j"]
   [:k :<C-w>k "k"]
   [:l :<C-w>l "l"]
   [:h :<C-w>h "h"]
   [:J :<C-w>J "J"]
   [:K :<C-w>K "K"]
   [:L :<C-w>L "L"]
   [:H :<C-w>H "H"]
   [:n :gt "tab next"]
   [:p :gT "tab previous"]
   [:N (cmd "tabmove +1") "move tab up"]
   [:P (cmd "tabmove -1") "move tab down"]
   [:t ::<C-u>tabnew<CR> "tab new"]
   [:T ":<C-u>Unite tab<CR>" "show tab"]
   [:o (cmd :only) "only (close all windows(splits) except the current one)"]
   [:s (cmd :sp) "split-horizontally"]
   [:v (cmd :vs) "split-vertically"]
   [:d (cmd :bd) "delete tab"]
   [";" ":<c-u>sp<cr><c-w>J:<c-u>res 10<cr>:<C-u>terminal<cr>:<c-u>setlocal noequalalways<cr>i" "vscode like terminal"] ])

(nmaps
  (space :q)
  :quit
  [[:q (cmd :q) :quit]
   [:a (cmd :q!):quit!]
   [:b (cmd :bd) "delete buffer"]
   [:c (cmd :close) "window close"]])

(nmaps
  (space :m)
  :me
  [[:nh :<cmd>noh<cr> "turn off search highlighting until the next search"]
   [:sd (cmd "e %:h") "show current directory"]
   [:sf "<cmd>source %<cr>" "source a current file"]
   [:pc "<cmd>Unite colorscheme -auto-preview<cr>" "preview colorschemes"]
   [:u (cmd :update) :update]
   [:rs ::%s/\s\+$//ge<cr> "remove trailing spaces"]
   [:a ":vim TODO ~/org/*.org<cr>" "agenda"]
   [:ts ":%s/\t/ /g<cr>" "replace tab with space"]
   [:cd ":<c-u>lcd %:p:h<cr>" "move current directory to here"]
   [(br :l :f) ":<c-u>set clipboard+=unnamed<cr>" "enable clipboard"]
   [(br :r :f) ":<c-u>set clipboard-=unnamed<cr>" "disable clipboard"]
   [(br :l :x) ":<c-u>setlocal conceallevel=1<cr>" "hide conceal"]
   [(br :r :x) ":<c-u>setlocal conceallevel=0<cr>" "show conceal"]
   [:fn (la (print (vim.fn.expand :%:t))) "show file name"]
   [:fp (la (print (vim.fn.expand :%:p))) "show file path"]
   [:ft (la (if (= vim.o.foldmethod :indent)
              (tset vim.o :foldmethod :marker)
              (tset vim.o :foldmethod :indent))
            (print (.. "foldmethod is now " vim.o.foldmethod))) "toggle foldmethod"]
   [:lm (la (let [{: cursor : strlen : getline} vim.fn]
              (cursor 0 (/ (strlen (getline :.)) 2)))) "go middle of a line"]
   [:m (la (let [buf (vim.api.nvim_create_buf false true)]
             (vim.api.nvim_buf_set_lines buf 0 100 false ((req-f :split :util.string) (vim.api.nvim_exec "messages" true ) "\n"))
             (vim.api.nvim_open_win buf true {:relative :editor :style :minimal :row 3 :col 3 :height 40 :width 150}))) "show message"]
   [:no (la (let [width 27
                  height 30
                  buf (vim.api.nvim_create_buf false true)]
              (vim.api.nvim_buf_set_option buf :filetype :org)
              (vim.api.nvim_buf_set_lines buf 0 height false ["Note"])
              (vim.api.nvim_open_win buf true {:relative :editor
                                               :style :minimal
                                               :border :rounded
                                               :row 3
                                               :col (- vim.o.columns width)
                                               :height height
                                               :width width}))) "memo"]
   ])

(when (vim.fn.has :mac)
  (map :n "<space>m?" "<cmd>!open dict://<cword><cr>" "[me] mac dictionary"))

(epi _ k (require :core.map.map) (map (unpack k)))

;;; plugins
(epi _ name [:bracket :veil]
     ((-> (.. :core.map. name) require (. :setup))))


{}
