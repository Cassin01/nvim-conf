(import-macros {nmaps : cmd : space : la} :kaza.macros)
(local {: aus} (require :kaza.au))

(nmaps
  (space :d)
  :diagnostic
  [[:q (cmd "lua vim.diagnostic.setloclist()") :show]]
  [[:n (cmd "lua vim.diagnostic.goto_next()") :next]
   [:p (cmd "lua vim.diagnostic.goto_prev()") :prev]])

(aus :my_lsp [[:CursorHold (la (vim.diagnostic.setloclist {:open false})) {:pattern :*.rs}]
              [:FileType (la (let [line_num (vim.fn.line :$)]
                               (tset vim.wo :wrap true)
                               (vim.cmd (.. "resize " line_num)))) {:pattern :qf}]])

{}
