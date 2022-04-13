(import-macros {: la} :kaza.macros)
(import-macros {: epi} :util.macros)

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
 [:i (c :p) "<up>" "up"]
 [:i (c :n) "<down>" "down"]
 [:i (c :f) "<right>" "right"]
 [:i (c :b) "<left>" "left"]
 [:i (c :e) "<end>" "jump to EOL"]
 [:i (c :a) "<c-o>^" "jump to BOL"]
 [:i (c-s :f) "<esc>ea" "<C-S-f> move forward one word"]
 [:i (c-s :b) "<esc>bi" "<C-S-b> move to one word later"]
 [:i (c :j) "<esc>o" "<C-j> insert new line bellow and jump"]
 [:i (c :o) "<esc>O" "<C-o> insert new line above and jump" ]

 ;; copy & paste
 [:i (c :d) "<Del>" "Delete"]
 [:i (c :h) "<c-h>" "backspace "]
 [:i (c "@") "<c-o>v" "mark the start point of yank"]
 [:i (c :k) "<C-r>=v:lua.__kaza.f.retrive_till_tail()<CR>" "delete from cursor to EOL"]

 ;; undo & redo
 [:v (c :w) "y`]i" " yank"]
 [:v (c-s :w) "x`]i" "delete and yank"]
 [:i (c :y) "<esc>pa" "paste"]
 [:i (c :-) "<esc>ua" "undo"]
 [:i (c :+) "<esc><c-r>a" "redo"]
 [:i (.. (c :x) :0) "<c-o><c-w>q" "close a window"]
 [:i (.. (c :x) :2) "<c-o>:<c-u>vs<cr>" "split-vertically"]
 [:i (.. (c :x) :3) "<c-o>:<c-u>sp<cr>" "split-horizontally"]
 [:i (.. (c :x) :o) "<c-o><c-w>w" "move to other windows"]

 ;; file
 [:i (.. (c :x) (c :s)) "<c-o>:w<cr>" "save-file"]
 ])

(fn bmap [bufnr mode key cmd ?desc]
  "[:number :string :string [:string :function] :string :nil]"
  (let [desc (.. "[Evil] " (or ?desc ""))]
    (if
      (= (type cmd) :string)
      (vim.api.nvim_buf_set_keymap bufnr mode key cmd {:noremap true :silent true :desc desc})
      (= (type cmd) :function)
      (vim.api.nvim_buf_set_keymap bufnr mode key "" {:callback cmd :noremap true :silent true :desc desc})
      (assert false "invalid cmd type"))))

(fn set-maps []
  (epi _ k evil-maps (bmap 0 (unpack k))))

(fn del-maps []
  (epi _ k evil-maps (vim.api.nvim_buf_del_keymap 0 (. k 1) (. k 2))))

(fn u-cmd [name f ?opt]
       (let [opt (or ?opt {})]
         (tset opt :force true)
         (vim.api.nvim_add_user_command name f opt)))

(u-cmd
  :EvilEnable
  (la (set-maps)
      (print "EvilMode Enabled")))

(u-cmd
  :EvilDisable
  (la (del-maps)
      (print "EvilMode Disabled")))

{}
