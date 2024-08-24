(import-macros {: ep : epi : req-f} :util.macros)

(ep key val (require :core.opt.g) (tset vim.g key val))
(ep key val (require :core.opt.opts) (tset vim.o key val))
(epi _ val (require :core.opt.cmd) (vim.cmd val))

; (tset (. _G.__kaza :f) :dump (req-f :dump :util.list))

(vim.opt.clipboard:append {:unnamedplus true
                           :unnamed true})
(tset vim.opt :listchars {:tab "▸▹┊"
                          ; :trail "□"
                          :trail "⋅"
                          :extends "❯" ; Character to show in the last column, when `wrap` is off
                          :precedes "❮"
                          ; :space "⋅"
                          ; :eol "↴"
                          :nbsp :+
                          })

(tset vim.opt :fillchars {:vert " "
                          :vertleft " "
                          :vertright " "
                          :verthoriz " "
                          ;:horiz " "
                          :horizup " "
                          :horizdown " "
                          :eob " "})

;; Tips: This is explicit declaration.
;; I declare this for me not forget.
; Use a line cursor within insert mode and a block cursor everywhere else.
; Reference chart of values:
; - Ps = 0 -> blinking block.
; - Ps = 1 -> blinking block (default).
; - Ps = 2 -> steady block.
; - Ps = 3 -> blinking underline.
; - Ps = 4 -> steady underline.
; - Ps = 5 -> blinking bar (xterm)
; - Ps = 6 -> steady bar (xterm)
; (when (vim.fn.has "vim_starting")
;   ; (print "Setting cursor shape")
;   ;; SI for insert mode
;   ; (vim.cmd "let &t_SI .= \"\\e[12;red\\a\"")
;   (vim.cmd "let &t_SI .= \"\\e[3 q\"")
;   ;; EI for all mode except for insert mode
;   (vim.cmd "let &t_EI .= \"\\e[2 q\"")
;   )

;; undo
; (if (vim.fn.has :persistent_undo)
;   (let [target-path (vim.fn.expand "~/.local/share/nvim/undo")]
;     (if (not (vim.fn.isdirectory target-path))
;       (vim.fn.mkdir target-path :p 0700))
;     (tset vim.o :undodir target-path)
;     (tset vim.o :undofile true)))

;; ignore some messages
 (let
   [notify (. vim :notify)
           nvim_notify (. vim :api :nvim_notify)]
   (tset
     vim :notify
     (lambda [msg ...]
       nil
       ; (when
       ;   (or
       ;     (: msg :match "warning: multiple different client offset_encodings")
       ;     (: msg :match "treesitter")
       ;     (: msg :match "Error executing vim.schedule lua callback:"))
       ;   (lua :return))
       ; (notify msg ...)
       ))
   (tset (. vim :api)
         :nvim_notify 
         (lambda [msg ...] nil)))
