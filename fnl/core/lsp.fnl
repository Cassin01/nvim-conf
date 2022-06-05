(import-macros {: nmaps : cmd : space : la} :kaza.macros)
(local {: aus} (require :kaza.au))

;; nmaps(prefix, prefix description, arguments that will be unpacked)
(nmaps
  (space :d)
  :diagnostic
  [[:q (cmd "lua vim.diagnostic.setloclist()") :show]
   [:n (cmd "lua vim.diagnostic.goto_next()") :next]
   [:p (cmd "lua vim.diagnostic.goto_prev()") :prev]])

;; aus(group, arguments that will be unpacked)
(aus :lsp-diagnostic
     [[:CursorHold (la (vim.diagnostic.setloclist {:open false})) {:pattern [:*.rs :*.ts :*.tex]}]
      [:FileType (la (let [line_num (vim.fn.line :$)]
                       ; (tset _G.__kaza.v :diagnostic_master_buf (vim.api.nvim_get_current_buf))
                       (tset vim.wo :wrap true)
                       (vim.cmd (.. "resize " line_num)))) {:pattern :qf}]])

{}
