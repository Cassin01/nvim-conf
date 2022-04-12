(local {: in?} (require :util.table1))
(import-macros {: def : ep} :util.macros)

(def prefix [prefix plug-name] [:string :string :string]
  "add prefix with doc"
  (tset _G.__kaza.prefix prefix plug-name)
  prefix)

(def _overwrite [org-tbl tbl] [:table :table :table]
  (ep k v tbl (tset org-tbl k v))
  org-tbl)

(def prefix-o [mode prefix name ?opt] [:string :string :string :?table :table]
  ;(tset _G.__kaza.prefix prefix name) ;FUTURE
  (local sign (.. "[" name "] "))
  {:map (λ [key cmd desc]
          (vim.api.nvim_set_keymap mode
                                   (.. prefix key)
                                   cmd
                                   (_overwrite {:noremap true :silent true :desc (.. sign desc)} (or ?opt {}))))
   :map-buf (λ [bufnr key cmd desc]
              (vim.api.nvim_buf_set_keymap bufnr
                                           mode
                                           (.. prefix key)
                                           cmd
                                           (_overwrite {:noremap true :silent true :desc (.. sign desc)} (or ?opt {}))))
   :map-f (λ [key callback desc]
            (vim.api.nvim_set_keymap mode
                                     (.. prefix key)
                                     ""
                                     (_overwrite {:callback callback
                                      :noremap true :silent true :desc (.. sign desc)} (or ?opt {}))))})

(def rt [str] [:string :string]
  "replace termcode"
  (vim.api.nvim_replace_termcodes str true true true))

;; map

(def map [mode key cmd desc] [:string :string [:string :function] :string :nil]
  (if (= (type cmd) :string)
    (vim.api.nvim_set_keymap mode key cmd {:noremap true :silent true :desc desc})
    (vim.api.nvim_set_keymap mode key "" {:callback cmd :noremap true :silent true :desc desc})))

(def bmap [bufnr mode key cmd desc] [:number :string :string [:string :function] :string :nil]
  (if (= (type cmd) :string)
    (vim.api.nvim_buf_set_keymap bufnr mode key cmd {:noremap true :silent true :desc desc})
    (vim.api.nvim_buf_set_keymap bufnr mode key "" {:callback cmd :noremap true :silent true :desc desc})))


{: map : bmap : prefix-o : prefix : rt}
