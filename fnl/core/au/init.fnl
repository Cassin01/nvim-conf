(import-macros {: epi} :util.macros)
(import-macros {: au! : la : plug} :kaza.macros)
(local {: concat-with} (require :util.list))
(local {: hi-clear} (require :kaza.hi))
(local vf vim.fn)
(local va vim.api)
(local create_autocmd vim.api.nvim_create_autocmd)
(local create_augroup vim.api.nvim_create_augroup)
(local buf_set_option vim.api.nvim_buf_set_option)
(local win_set_option vim.api.nvim_win_set_option)
(local buf_set_keymap vim.api.nvim_buf_set_keymap)

;; remind cursor position
(au! :restore-position :BufReadPost (when (and (> (vim.fn.line "'\"") 1)
                                              (<= (vim.fn.line "'\"") (vim.fn.line "$")))
                                     (vim.cmd "normal! g'\"")))

;;; highlight
;; WARN Should be read before color scheme is loaded.
(au! :hi-default :BufWinEnter (each [_ k (ipairs (require :core.au.hi))]
                       (vim.api.nvim_set_hl 0 (unpack k))))

;; annotations
(fn link [name opt]
  (let [data (vim.api.nvim_get_hl_by_name name 0)]
    (each [k v (pairs opt)]
      (tset data k v))
    data))
(fn blightness [color p]
  (let
    [r (string.sub (vf.printf :%0x (math.floor (* (tonumber (string.sub color 2 3) 16) p))) -2 -1)
     g (string.sub (vf.printf :%0x (math.floor (* (tonumber  (string.sub color 4 5) 16) p))) -2 -1)
     b (string.sub (vf.printf :%0x (math.floor (* (tonumber (string.sub color 6 7) 16) p))) -2 -1)]
    (.. :# r g b)))
(fn get-hl [name part]
  "name: hlname
  part: bg or fg"
  (let [target (va.nvim_get_hl_by_name name 0)]
    (if
      (= part :fg)
      (.. :# (vf.printf :%0x (. target :foreground)))
      (= part :bg)
      (.. :# (vf.printf :%0x (. target :background)))
      (error "part: bg or fg"))))

(au! :match-hi :ColorScheme (each [_ k (ipairs [;[:Tabs {:bg (blightness (get-hl :Normal :bg) 0.9)}]
                                                [:TrailingSpaces {:bg :#FFa331}]
                                                [:DoubleSpace {:bg :#cff082}]
                                                [:TodoEx {:bg :#44a005 :fg :#F0FFF0}]
                                                [:FoldMark (link :Comment {:fg (blightness (get-hl :Comment :fg) 0.9)})]
                                                [:CommentHead (link :Comment {:fg :#727ca7})]])]
                             (vim.api.nvim_set_hl 0 (unpack k))))
(au! :match [:BufWinEnter] ((. (require :core.au.match) :add-matchs)))

; terminal mode
(au! :term-conf :TermOpen (do
                           (win_set_option 0 :relativenumber false)
                           (win_set_option 0 :number false)))

; vim grep
(create_autocmd
  :QuickFixCmdPost
  {:pattern :*grep*
   :command :cwindow
   :group (create_augroup :grep-cmd {:clear true})})

;; settings for global status

;; pattern {{{
(fn tex_math []
  (buf_set_keymap 0 :i "$<enter>" "$$$$<left><cr><cr><up>" {:noremap true})
  (buf_set_keymap 0 :i "$$" "$$<left>" {:noremap true}))

(create_autocmd
  :ColorScheme
  {:callback (λ []
               (if (= vim.o.laststatus 3)
                 (hi-clear :VerSplit)))
   :group (create_augroup :global-status {:clear true})})

(local pattern (create_augroup :pattern {:clear true}))
(create_autocmd
  [:BufRead :BufNewFile]
  {:callback (λ []
               (buf_set_option 0 :commentstring "// %s")
               (win_set_option 0 :foldmethod :indent)
               (buf_set_keymap 0
                               :i
                               :/*
                               :<kDivide><kMultiply><space><space><kMultiply><kDivide><left><left><left>
                               {:noremap true}))
   :pattern [:*.c :*.h :*.cpp :*.rs]
   :group pattern})
(create_autocmd
  [:BufRead :BufNewFile]
  {:callback (λ []
              (win_set_option 0 :foldmethod :indent))
   :pattern [:*.py]
   :group pattern})
(create_autocmd
  [:BufRead :BufNewFile]
  {:callback (λ []
              (win_set_option 0 :foldmethod :marker)
              (buf_set_keymap 0 :i "\"" "\"" {:noremap true}))
   :pattern [:*.vim]
   :group pattern})
(create_autocmd
  [:BufRead :BufNewFile]
  {:callback (λ []
               (tset vim.g :tex_conceal "")
               (tex_math)
               (local indent 2)
               (tset vim.bo :tabstop indent)
               (tset vim.bo :shiftwidth indent)
               (tset vim.bo :softtabstop indent)
               (vim.cmd "setlocal iskeyword+=\\")
               (if (. vim.g :vim-auto-save)
                 (tset vim.g :auto_save 1)))
   :pattern [:*.tex]
   :group pattern})
(create_autocmd
  [:BufRead :BufNewFile]
  {:callback (λ []
               (win_set_option 0 :foldenable false)
               (tex_math))
   :pattern [:*.md]
   :group pattern})
(create_autocmd
  [:BufRead :BufNewFile]
  {:callback (λ []
               (buf_set_option 0 :shiftwidth 2)
               (vim.cmd "setlocal iskeyword-=_")
               (vim.cmd "setlocal iskeyword-=-"))
   :pattern [:*.lisp :*.fnl]
   :group pattern})

;;; sche {{{
(local m-date "'^\\d\\d\\d\\d/\\d\\d/\\d\\d'")
(local l-date "%d%d%d%d/%d%d/%d%d")
(local {: u-cmd} (require :kaza))
(macro thrice-if [sentense lst]
  (fn car [x ...] x)
  (fn cdr [x ...] [...])
  (fn step [l]
    (if (not= (length l) 0)
      (let [v (car (unpack l))]
        `(if (string.match ,sentense (.. :^%s+ ,v :.*$))
           (let [kind# (string.match ,sentense (.. "^%s+(" ,v ").*$"))
                 desc# (string.match ,sentense (.. "^%s+" ,v "%s+(.*)%s*$"))]
             {kind# desc#})
           ,(step (cdr (unpack l)))))
      sentense))
  (step lst))
(fn append [lst x]
  (tset lst (+ (length lst) 1) x)
  lst)
(fn pack [line list]
  (local elm (thrice-if line ["@" "#" "%+" "%-" "!" "%."]))
  (if (or (= list nil) (= (length list) 0) )
    [elm]
    (append list elm)))
(fn parser [b-lines]
  (var ret {})
  (var date "")
  (each [_ v (ipairs b-lines)]
    (if (not= (string.match v (.. :^ l-date :.*$)) nil)
      (do
        (set date (string.match v (.. :^ l-date)))
        (tset ret date []))
      (tset ret date (pack v (. ret date)))))
  ret)
(u-cmd
  :ParseSche
  (λ []
    (local lines (vim.api.nvim_buf_get_lines 0 0 -1 1))
    (local ob (parser lines))
    (print (vim.inspect ob))))
(fn syntax [group pat]
  (vim.cmd
    (concat-with " "
      :syntax :match group pat)))
(macro weekday []
  (let [keywords# [:Fri :Mon :Tue :Wed :Thu]]
    (.. "'" :\<\ "(" (table.concat keywords# :\|) :\ ")'")))
(au! :match-hi :ColorScheme 
     (each [_ k (ipairs [[:GCalendarMikan {:fg :#F4511E}]
                         [:GCalendarPeacock {:fg :#039BE5}]
                         [:GCalendarGraphite {:fg :#616161}]
                         [:GCalendarSage {:fg :#33B679}]
                         [:GCalendarBanana {:fg :#f6bf26}]
                         [:GCalendarLavender {:fg :#7986cb}]
                         [:GCalendarTomato {:fg :#d50000}]
                         [:GCalendarFlamingo {:fg :#e67c73}]
                         ])]
       (vim.api.nvim_set_hl 0 (unpack k))))
(create_autocmd
  [:BufReadPost :BufNewFile]
  {:callback (λ []
               (tset vim.bo :filetype :sche)
               (local indent 2)
               (tset vim.bo :tabstop indent)
               (tset vim.bo :shiftwidth indent)
               (tset vim.bo :softtabstop indent)
               (syntax :Comment "'^;.*'" )
               (syntax :Statement "'^\\(\\d\\|\\d\\d\\)月'")
               (syntax :Function m-date)
               (syntax :Special "'\\s\\+@'")
               (syntax :GCalendarBanana "'\\s\\++'")
               (syntax :Special "'\\s\\+-'")
               (syntax :GCalendarLavender "'\\s\\+#'")
               (syntax :GCalendarBanana "'\\s\\+\\.'")
               (syntax :GCalendarFlamingo "'\\s\\+!'")
               (syntax :GCalendarGraphite (weekday))
               (syntax :GCalendarMikan "'\\<Sun\\>'")
               (syntax :GCalendarPeacock "'\\<Sat\\>'")
               (syntax :GCalendarSage (vim.fn.strftime "'%Y/%m/%d'")))
   :pattern [:*.sche]})
;;; }}}
;; }}}


;;; plugin specific

;; packer
(create_autocmd
  :BufWritePost
  {:command :PackerCompile
   :pattern :plugs.fnl
   :group (create_augroup :packer-compile {:clear true})})

;; ref-view
(au! :ref-view
    :FileType
    (let [{: bmap} (require :kaza.map)]
      (epi _ k [[:n :b (plug "(ref-back)") :back]
                [:n :f (plug "(ref-forward)") :forward]
                [:n :q :<c-w>c :quit]]
           (bmap 0 (unpack k))))
    {:pattern :ref})

;; copilot
(au! :reload-copilot
     :VimEnter
     (vim.cmd "Copilot restart")
     ; (do
     ;   (local {: async-cmd} (require :kaza.cmd))
     ;   (async-cmd "Copilot restart"))
     )
