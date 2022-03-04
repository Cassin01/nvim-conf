(fn map [mode key cmd ?option]
   (let [option (or ?option {:noremap true :expr true})]
   (vim.api.nvim_set_keymap mode key cmd option)))

{: map}
