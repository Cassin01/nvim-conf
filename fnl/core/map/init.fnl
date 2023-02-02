(import-macros {: epi : req-f : unless} :util.macros)
(import-macros {: la : cmd : plug : space : br : nmaps} :kaza.macros)

(local {: map} (require :kaza.map))
(local vf vim.fn)
(local va vim.api)

; (map :n :<space> "<cmd>NormalWitch SPC<cr>" "wich")
(nmaps
  (space :w)
  :witch
  [[(space) (cmd "NormalWitch SPC") :space]
   ; [:\ (cmd "NormalWitch \\") :\]
   ; [:b (plug "(hwitch-bookmark)") "book mark"]
   ; [:n (plug "(hwitch-normal)") "normal wich"]
   [:u (plug "(hwitch-ultisnips)") "ultisnips"]
   [:t (plug "(hwitch-tex)") "tex"]
   ; [:r (cmd "REGWITCH") :register]
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
   [";" ":<c-u>sp<cr><c-w>J:<c-u>res 10<cr>:<C-u>terminal<cr>:<c-u>setlocal noequalalways<cr>i" "vscode like terminal"]])

(nmaps
  (space :q)
  :quit
  [[:q (cmd :q) :quit]
   [:a (cmd :q!):quit!]
   [:b (cmd :bd) "delete buffer"]
   [:c (cmd :close) "window close"]])

(when (vim.fn.has :mac)
  (map :n "<space>m?" "<cmd>!open dict://<cword><cr>" "[me] mac dictionary"))

(epi _ k (require :core.map.map) (map (unpack k)))

;; veil
(fn cdr [a ...]
  [...])
(epi _ k (require :core.map.veil.data)
     ; (print (vim.inspect (cdr (unpack k))))
     (vim.api.nvim_set_keymap (unpack (cdr (unpack k)))))

;;; caps lock
(for [i 65 90]
  (va.nvim_set_keymap :l (vf.nr2char (+ i 32)) (vf.nr2char i) {:noremap true :silent true :desc :caps}))

;;; plugins
(epi _ name [; :bracket
             ; :veil
             :nmap] ((-> (.. :core.map. name) require (. :setup))))

{}
