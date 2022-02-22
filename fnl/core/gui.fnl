(import-macros
  {:set-option se-
   :let-global let-g} :core.embedded)

(local M {})

(fn M.neovide-setting []
  (let-g neovide_cursor_vfx_mode "ripple"))

(if (vim.fn.exists _G.neovide)
  (M.neovide-setting))

M
