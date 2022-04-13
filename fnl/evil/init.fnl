(import-macros {: la} :kaza.macros)
(import-macros {: epi} :util.macros)
(local {: bmap} (require :kaza.map))

(local vf vim.fn)

(fn split-line-at-point []
    (let [line_text (vf.getline (vf.line :.))
          col (vf.col :.)
          text_after (string.sub line_text col)
          text_before (if (> col 1) (string.sub line_text 1 (- col 1)) "")]
      (values text_before text_after)))

(tset
  _G.__kaza.f
  :retrive_till_tail
  (λ []
    (let [(text_before text_after) (split-line-at-point)]
      (if (= (string.len text_after) 0)
        (vim.cmd "normal! J")
        (vf.setline (vf.line :.) text_before)))
    ""))

(macro c [c]
  (string.format "<C-%s>" c))

(macro c-s [c]
  (string.format "<C-S-%s>" c))

(local evil-maps
[
 ;; move
 [:i (c :p) "<up>" "<C-p>: up"]
 [:i (c :n) "<down>" "<C-n>: down"]
 [:i (c :f) "<right>" "<C-f>: right"]
 [:i (c :b) "<left>" "<C-b>: left"]
 [:i (c :e) "<end>" "<C-e>: jump to EOL"]
 [:i (c :a) "<c-o>^" "<C-a>: jump to BOL"]
 [:i (c-s :f) "<esc>ea" "<C-S-f> move forward one word"]
 [:i (c-s :b) "<esc>bi" "<C-S-b> move to one word later"]
 [:i (c :j) "<esc>o" "<C-j> insert new line bellow and jump"]
 [:i (c :o) "<esc>O" "<C-o> insert new line above and jump" ]

 ;; copy & paste
 [:i (c :d) "<Del>" "<C-d>: Delete"]
 [:i (c :h) "<c-h>" "<C-h>: backspace "]
 [:i (c "@") "<c-o>v" "<C-@>: mark the start point of yank"]
 [:i (c :k) "<C-r>=v:lua.__kaza.f.retrive_till_tail()<CR>" "<C-k>: delete from cursor to EOL"]

 ;; undo & redo
 [:v (c :w) "y`]i" "<C-w>: yank"]
 [:v (c-s :w) "x`]i" "<C-S-w>: delete and yank"]
 [:i (c :y) "<esc>pa" "<C-y>: paste"]
 [:i (c :-) "<esc>ua" "<C ->: undo"]
 [:i (c :+) "<esc><c-r>a" "<C +>: redo"]
 [:i (.. (c :x) :0) "<c-o><c-w>q" "<C-x>0: close a window"]
 [:i (.. (c :x) :2) "<c-o>:<c-u>vs<cr>" "<C-x>2; split-vertically"]
 [:i (.. (c :x) :3) "<c-o>:<c-u>sp<cr>" "<C-x>3: split-horizontally"]
 [:i (.. (c :x) :o) "<c-o><c-w>w" "<C-x>o: move to other windows"]

 ;; file
 [:i (.. (c :x) (c :s)) "<c-o>:w<cr>" "<C-x><C-s>: save-file"]
 ])

(fn set-maps []
  (epi _ k evil-maps (bmap 0 (unpack k))))

(fn del-maps []
  (epi _ k evil-maps (vim.api.nvim_buf_del_keymap 0 k)))


(fn u-cmd [name f ?opt]
       (let [opt (or ?opt {})]
         (tset opt :force true)
         (vim.api.nvim_add_user_command name f opt)))

(u-cmd
  :EvilStart
  (la
    (print "EvilMode Enabled")
    (set-maps)))

(u-cmd
  :EvilEnd
  (print "EvilMode Disabled")
  (la (del-maps)))

{}
