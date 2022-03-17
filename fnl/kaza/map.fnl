(local {: in?} (require :util.src.table1))

(fn map* [mode key cmd ?option]
   (let [option (or ?option {:noremap true :expr true})]
   (vim.api.nvim_set_keymap mode key cmd option)))

;;; register

(fn set-key [mode key description]
   (tset (. _G.__kaza.k mode) key description))

(fn map [mode key cmd description]
   (set-key "i" key description)
   (vim.api.nvim_set_keymap "i" key cmd {:noremap true :silent true}))

;;; map-f

(fn map-f [key lambda- name]
   "name must be unique. lambda- must be no arguments"
   (assert (not (in? name _G.__kaza.f)) "`name` must be unique!")
   (tset _G.__kaza.f name lambda-)
   (vim.api.nvim_set_keymap "n" key (.. "<cmd>call v:lua.__kaza.f." name "()<cr>") {:noremap true}))

{: map* : map : map-f}
