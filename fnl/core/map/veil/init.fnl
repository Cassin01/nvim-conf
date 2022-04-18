(local {: rt} :kaza.map)
(import-macros {: def : epi} :util.macros)

(macro m [c]
  (string.format :<M-%s> c))

(macro m-s [c]
  (string.format "<M-S-%s>" c))

(macro c [c]
  (string.format :<C-%s> c))

(macro c-s [c]
  (string.format :<C-S-%s> c))


(def map [mode key cmd desc] [:string :string [:string :function] :string :nil]
  (if (= (type cmd) :string)
    (vim.api.nvim_set_keymap mode key cmd {:noremap true :silent true :desc desc})
    (= (type cmd) :function)
    (vim.api.nvim_set_keymap mode key "" {:callback cmd :noremap true :silent true :desc desc :expr true})
    (error "invalid type for cmd")))


(local vf vim.fn )


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

(local data [
;; move
[:i (c :b) :<left> "left"]
[:i (c :f) "<right>" "right"]
[:i (c :a) :<c-o>^ "jump to BOL"]
[:i (c-s :a) :<c-a> "i_CTRL-A"]
[:i (c :e) "<end>" "jump to EOL"]
[:i (c :d) "<Del>" "delete"]
[:i (c :j) "<esc>o" "<C-j> insert new line bellow and jump"]
[:i (c :o) "<esc>O" "<C-o> insert new line above and jump"] ; *
[:i  (c-s :o) "<c-o>" "i_CTRL-O"]
[:i (c :k) "<C-r>=v:lua.__kaza.f.retrive_till_tail()<CR>" "delete from cursor to EOL"] ; *
[:i (c-s :k) "<c-k>" :i_CTRL-K]

;; copy & paste
[:i (c "@") "<c-o>v" "mark the start point of yank"]

; * insert the character which is above the cursor
[:i (c :y) "<esc>pa" "paste"]
[:i (c-s :y) "<c-y>" "i_CTRL-Y"]

;; undo & redo
[:i (c :-) "<esc>ua" "undo"]
[:i (c :+) "<esc><c-r>a" "redo"]

;; move
[:i (c :p) "<up>" "up"]
[:i (c :n) "<down>" "down"]
[:i (m :f) "<s-right>" "right"]
[:i (m :b) "<s-left>" "left"]
[:i (m :j) "<esc>o" "<C-j> insert new line bellow and jump"]
[:i (m :o) "<esc>O" "<C-o> insert new line above and jump" ]
[:i (m :<) "<esc>ggi" "beginning of buffer"]
[:i (m :>) "<esc>Gi" "end of buffer"]

;; window
[:i (.. (c :x) :0) "<c-o><c-w>q" "close a window"]
[:i (.. (c :x) :1) "<c-o>:<c-u>only<cr>" "delete-other-windows"]
[:i (.. (c :x) :2) "<c-o>:<c-u>vs<cr>" "split-vertically"]
[:i (.. (c :x) :3) "<c-o>:<c-u>sp<cr>" "split-horizontally"]
[:i (.. (c :x) :o) "<c-o><c-w>w" "move to other windows"]
[:i (.. (c :x) :k) "<c-o>:bdelete<cr>" "kill buffer"]

;; file
[:i (.. (c :x) (c :s)) "<c-o>:update<cr>" "save-file"]
])

(fn setup []
  (epi _ k data (map (unpack k))))

{: setup}
