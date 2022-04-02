(local {: in?} (require :util.src.table1))
(import-macros {: fn*} :util.src.macros)

(fn prefix [prefix plug-name]
   "add prefix with doc"
   (tset _G.__kaza.prefix prefix plug-name)
   prefix)

(fn prefix-o [prefix plug-name]
   (tset _G.__kaza.prefix prefix plug-name)
   {:map (λ [mode key cmd desc]
           (do 
             (assert (= (type mode) :string) "must be string")
             (assert (= (type key) :string) "must be string")
             (assert (= (type cmd) :string) "must be string")
             (assert (= (type desc) :string) "must be string"))
           (vim.api.nvim_set_keymap mode
                                    (.. prefix key)
                                    cmd
                                    {:noremap true :silent true :desc (.. "[" plug-name "] " desc)}))
    :map-f (λ [mode key callback desc]
             (do
               (assert (= (type mode) :string) "must be string")
               (assert (= (type key) :string) "must be string")
               (assert (= (type callback) :function) "must be function")
               (assert (= (type desc) :string) "must be string"))
             (vim.api.nvim_set_keymap mode
                                      (.. prefix key)
                                      ""
                                      {:callback callback
                                       :noremap true :silent true :desc (.. "[" plug-name "] " desc)}))})

(fn rt [str]
   "replace termcode"
  (vim.api.nvim_replace_termcodes str true true true))

(fn map [mode key cmd desc]
   (do (assert (= (type mode) :string) "must be string")
      (assert (= (type key) :string) "must be string")
      (assert (= (type cmd) :string) "must be string")
      (assert (= (type desc) :string) "must be string"))
   (vim.api.nvim_set_keymap mode key cmd {:noremap true :silent true :desc desc}))

(fn map-f [key lambda- name]
   "name must be unique. lambda- must be no arguments"
   (assert (not (in? name _G.__kaza.f)) "`name` must be unique!")
   (tset _G.__kaza.f name lambda-)
   (vim.api.nvim_set_keymap "n" key (.. "<cmd>call v:lua.__kaza.f." name "()<cr>") {:noremap true}))

{: map : map-f : prefix-o : prefix : rt}
