;;;; init.fnl

;;; set up zest
(let [zest (require :zest)]
  (zest.setup))

(vim.cmd "runtime init/plugin/plugin_install.init.vim")
(vim.cmd "runtime init/plugin/plugin_settings.init.vim")

(require :core)

(vim.cmd "runtime init/main/nnormap.init.vim")
(vim.cmd "runtime init/main/othermap.init.vim")
(vim.cmd "runtime init/color/color.init.vim")

;;; future

;; redirect command into register
;; https://vi.stackexchange.com/questions/8378/dump-the-output-of-internal-vim-command-into-buffer
