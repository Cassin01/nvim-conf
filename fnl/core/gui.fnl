(import-macros
  {:set-option se-
   :let-global let-g} :kaza.macros)

(fn neovide-setting []
  ;(tset vim.o :guifont "FiraCode Nerd Font:h19")
  (tset vim.o :guifont "HackGen Console:h12")
  (let-g neovide_cursor_vfx_mode "ripple"))

(when (vim.fn.exists _G.neovide)
  (neovide-setting))

{}
