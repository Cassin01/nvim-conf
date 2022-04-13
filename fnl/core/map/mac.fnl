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

[
 [:n "<space>m?" "<cmd>!open dict://<cword><cr>" "[me] mac dictionary"]

 ;; move
 [:i "π" "<up>" "<opt-p>: up"]
 [:i "˜" "<down>" "<opt-n>: down"]
 [:i "ƒ" "<right>" "<opt-f>: right"]
 [:i "∫" "<left>" "<opt-b>: left"]
 [:i "´" "<end>" "<opt-e>: jump to EOL"]
 [:i "å" "<c-o>^" "<opt-a>: jump to BOL"]
 [:i "Ï" "<esc>ea" "<shift><opt-f> move forward one word"]
 [:i "ı" "<esc>bi" "<shift><opt-b> move to one word later"]
 [:i "∆" "<esc>o" "<opt-j> insert new line bellow and jump"]
 [:i "ø" "<esc>O" "<opt-o> insert new line above and jump" ]

 ;; copy & paste
 [:i "∂" "<Del>" "<opt-d>: Delete"]
 [:i "˙" "<c-h>" "<opt-h>: backspace "]
 [:i "€" "<c-o>v" "<opt-@>: mark the start point of yank"]
 [:i "˚" "<C-r>=v:lua.__kaza.f.retrive_till_tail()<CR>" "<opt-k>: delete from cursor to EOL"]

 ;; undo & redo
 [:v "∑" "y`]i" "<opt-w>: yank"]
 [:v "„" "x`]i" "<opt-w>: delete and yankk"]
 [:i "¥" "<esc>pa" "<opt>y: paste"]
 [:i "—" "<esc>ua" "<opt ->: undo"]
 [:i "±" "<esc><c-r>a" "<opt +>: redo"]
 [:i "≈0" "<c-o><c-w>q" "<opt-x>0: close a window"]
 [:i "≈2" "<c-o>:<c-u>vs<cr>" "<opt-x>2; split-vertically"]
 [:i "≈3" "<c-o>:<c-u>sp<cr>" "<opt-x>3: split-horizontally"]
 [:i "≈o" "<c-o><c-w>w" "<opt-x>o: move to other windows"]

 ;; file
 [:i "≈ß" "<c-o>:w<cr>" "<opt-x><opt-s>: save-file"]
 ]
