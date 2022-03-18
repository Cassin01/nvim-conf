(local {: in?} (require :util.src.table1))
(import-macros {: fn*} :util.src.macros)

(fn prefix [prefix document]
   "add prefix with doc"
   (tset _G.__kaza.prefix prefix document)
   prefix)

;;; register

(fn set-key [mode key description]
   (tset (. _G.__kaza.k mode) key description))

(fn map [mode key cmd desc]
   (do (assert (= (type mode) :string) "must be string")
      (assert (= (type key) :string) "must be string")
      (assert (= (type cmd) :string) "must be string")
      (assert (= (type desc) :string) "must be string"))

   ;(fn* map {:mode :string :key :string :cmd :string :desc :string}
         (vim.api.nvim_set_keymap mode key cmd {:noremap true :silent true :desc desc}))

   ;;; map-f

   (fn map-f [key lambda- name]
      "name must be unique. lambda- must be no arguments"
      (assert (not (in? name _G.__kaza.f)) "`name` must be unique!")
      (tset _G.__kaza.f name lambda-)
      (vim.api.nvim_set_keymap "n" key (.. "<cmd>call v:lua.__kaza.f." name "()<cr>") {:noremap true}))

   {: map : map-f : prefix}
