(if (= _G._kaza nil)
  (let [kaza (require :kaza)]
    (kaza.setup)))

(vim.cmd "runtime vim/secret.vim")
(vim.cmd "runtime vim/plugin_install.vim")
(vim.cmd "runtime vim/plugin_settings.vim")
(require :core)
