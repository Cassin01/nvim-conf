(fn _callback [group event callback ?opt]
  (let [opt {:callback callback
             :group group}]
    (each [k v (pairs (or ?opt {}))]
      (tset opt k v))
    (vim.api.nvim_create_autocmd event opt)))

(fn _command [group event command ?opt]
  (let [opt {:command command
             :group group}]
    (each [k v (pairs (or ?opt {}))]
      (tset opt k v))
    (vim.api.nvim_create_autocmd event opt)))

(fn au-call [group event body ?opt]
    (if
      (= (type body) :function) (_callback group event body ?opt)
      (= (type body) :string) (_command group event body ?opt)
      (print "au: body must be a function or string" body)))

(fn au [group-name event obj ?opt]
  (let [group (vim.api.nvim_create_augroup group-name {:clear true})]
    (au-call group event obj ?opt)))

(fn aus [group-name list]
  "list: event obj ?opt"
  (let [group (vim.api.nvim_create_augroup group-name {:clear true})]
    (each [_ v (ipairs list)]
    (au-call group (unpack v)))))

{: au
 : aus}
