(import-macros {: epi : req-f : unless} :util.macros)
(import-macros {: la : cmd : plug : space : br : nmaps} :kaza.macros)
(local vf vim.fn)

;;; util {{{
(fn concat-with [d ...]
  (table.concat [...] d))
;;; }}}
(fn setup []
(nmaps
  (space :m)
  :me
  [[:d "<cmd>:delm! | delm A-Z0-9<cr>" "Delete all marks"]
   [:nh :<cmd>noh<cr> "turn off search highlighting until the next search"]
   ; [:sd (la (let [mother-dir (vf.expand :%:h)
   ;                tree-cmd (if
   ;                           (not= (. (. (require :telescope) :extensions) :file_browser) nil)
   ;                             "Telescope file_browser path="
   ;                           (vf.exists ::Neotree)
   ;                             "Neotree "
   ;                           "e ")]
   ;            (vim.cmd (.. tree-cmd (if (not= mother-dir "")
   ;                         mother-dir
   ;                         (vf.getcwd)))))) "show current directory"]
   [:sd
    (la (let [mother-dir (vf.expand :%:h)
              path (if (= mother-dir "") (vf.getcwd) mother-dir)
              file_browser (. (. (. (require :telescope) :extensions) :file_browser) :file_browser)]
          (file_browser {:path path
                         :depth 4}))) "show curent directory"]
   [:sf "<cmd>source %<cr>" "source a current file"]
   [:se (la (let [query (vf.input "query: ")]
              (vim.cmd (concat-with " " :Websearch query)))) :web-search] ; WARN: depend on the native command Websearch
   [:pc "<cmd>Unite colorscheme -auto-preview<cr>" "preview colorschemes"]
   [:u (cmd :update) :update]
   [:rs ::%s/\s\+$//ge<cr> "remove trailing spaces"]
   ["r," (la
           (vim.cmd "%s/、/, /ge")
           (vim.cmd "%s/，/, /ge"))
           "replace `,`"]
   ["r." (la
           (vim.cmd "%s/。/. /ge")
           (vim.cmd "%s/．/. /ge"))
           "replace `.`"]
   [:a ":vim TODO ~/org/*.org<cr>" "agenda"]
   [:ts ":%s/\t/ /g<cr>" "replace tab with space"]
   [:cd ":<c-u>lcd %:p:h<cr>" "move current directory to here"]
   [(br :r :f) ":<c-u>set clipboard+=unnamed<cr>" "enable clipboard"]
   [(br :l :f) ":<c-u>set clipboard-=unnamed<cr>" "disable clipboard"]
   [(br :r :x) ":<c-u>setlocal conceallevel=1<cr>" "hide conceal"]
   [(br :l :x) ":<c-u>setlocal conceallevel=0<cr>" "show conceal"]
   [(br :l :c) (la (vim.cmd (.. "colo " vim.g.colors_name))) :recover-color]
   [(br :r :c) (la (vim.cmd "hi Normal guibg=NONE ctermbg=NONE")
                   (vim.cmd "hi CursorLine guibg=NONE")
                   (vim.cmd "hi StatusLine guibg=NONE guifg=#727169")
                   (vim.cmd "hi StatusLineNC guibg=NONE guifg=#727169")
                   (vim.cmd "hi LineNr guibg=NONE")
                   (vim.cmd "hi SignColumn guibg=NONE")
                   (vim.cmd "hi Folded guibg=NONE")
                   (vim.cmd "hi FoldColumn guibg=NONE")

                   (fn bufferline []
                     (local {: unfold-iter} (require :util.list))
                     (local res (vim.api.nvim_exec "highlight" true))
                     (local lines (unfold-iter (res:gmatch "([^\r\n]+)")))
                     (each [_ line (ipairs lines)]
                       (local elements (unfold-iter (line:gmatch "%S+")))
                       (local hi-name (. elements 1))
                       (when (not= hi-name nil)
                         (when (not= (hi-name:match "^BufferLine.*$") nil)
                           (vim.cmd (.. "hi " hi-name " guibg=NONE"))))))
                   (bufferline)) :clear-color]
   [:fn (la (print (vim.fn.expand :%:t))) "show file name"]
   [:fp (la (print (vim.fn.expand :%:p))) "show file path"]
   [:ft (la (if (= vim.o.foldmethod :indent)
              (tset vim.o :foldmethod :marker)
              (tset vim.o :foldmethod :indent))
            (print (.. "foldmethod is now " vim.o.foldmethod))) "toggle foldmethod"]
   [:fo (la (vim.lsp.buf.format)) :format-buf]
   [:lm (la (let [{: cursor : strlen : getline} vim.fn]
              (cursor 0 (/ (strlen (getline :.)) 2)))) "go middle of a line"]
   [:m (la (let [buf (vim.api.nvim_create_buf false true)]
             (vim.api.nvim_buf_set_lines buf 0 100 false ((req-f :split :util.string) (vim.api.nvim_exec "messages" true ) "\n"))
             (vim.api.nvim_open_win buf true {:relative :editor :style :minimal :row 3 :col 3 :height 40 :width 150}))) "show message"]
   [:em (la (let [width 27
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
   ;; TODO: I want to use this as a schedule.
   [:ew (la (let [width 27
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
                                               :width width}))) "schedule"]
   ]))

{: setup}
