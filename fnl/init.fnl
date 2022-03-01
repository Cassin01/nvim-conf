(if _G._hajikami
  (let [kaza (require :nvim)]
    (kaza.setup)))

(vim.cmd "runtime vim/plugin_install.vim")
(vim.cmd "runtime vim/plugin_settings.vim")
(require :core)
(vim.cmd "runtime vim/nnormap.vim")
(vim.cmd "runtime vim/othermap.vim")
(vim.cmd "runtime vim/color.vim")
