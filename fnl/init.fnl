;;;; init.fnl
;; set up zest
(let [zest (require :zest)]
  (zest.setup))

; (module nvim-config
;   {autoload {a aniseed.core}})
; (import-macros
;   {:opt-prepend opt^} :zest.macros)

(vim.cmd "runtime init/plugin/plugin_install.init.vim")
(vim.cmd "runtime init/plugin/plugin_settings.init.vim")
(require :core.options)
(vim.cmd "runtime init/main/nnormap.init.vim")
(vim.cmd "runtime init/main/othermap.init.vim")
(vim.cmd "runtime init/color/color.init.vim")
