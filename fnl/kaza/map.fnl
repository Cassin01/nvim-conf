(local {: in?} (require :util.src.table1))

(fn map [mode key cmd ?option]
   (let [option (or ?option {:noremap true :expr true})]
   (vim.api.nvim_set_keymap mode key cmd option)))

;;; map-f

(fn _map-f [key name]
   (let [option {:noremap true}]
   (vim.api.nvim_set_keymap "n" key (.. "<cmd>call v:lua.__kaza.f." name "()<cr>") option)))

(fn map-f [key lambda- name]
   "name must be unique. lambda- must be no arguments"
   (assert (not (in? name _G.__kaza.f)) "`name` must be unique!")
   (tset _G.__kaza.f name lambda-)
   (_map-f key name))

{: map : map-f}
