(local {: in?} (require :util.src.table1))
(import-macros {: def} :util.src.macros)

(def prefix [prefix plug-name] [:string :string :string]
  "add prefix with doc"
  (tset _G.__kaza.prefix prefix plug-name)
  prefix)

(def prefix-o [mode prefix name] [:string :string :string :table]
  ;(tset _G.__kaza.prefix prefix name)
  (local sign (.. "[" name "] "))
  {:map (λ [key cmd desc]
          (vim.api.nvim_set_keymap mode
                                   (.. prefix key)
                                   cmd
                                   {:noremap true :silent true :desc (.. sign desc)}))
   :map-f (λ [key callback desc]
            (vim.api.nvim_set_keymap mode
                                     (.. prefix key)
                                     ""
                                     {:callback callback
                                      :noremap true :silent true :desc (.. sign desc)}))})

(def rt [str] [:string :string]
  "replace termcode"
  (vim.api.nvim_replace_termcodes str true true true))

(def map [mode key cmd desc] [:string :string :string :string :nil]
  (vim.api.nvim_set_keymap mode key cmd {:noremap true :silent true :desc desc}))

{: map : prefix-o : prefix : rt}
