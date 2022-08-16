(import-macros
  {: set-o
   : let-g} :kaza.macros)

(fn neovide-setting []
  ; (tset vim.o :guifont "Hack Nerd Font:h16")
  (tset vim.o :guifont "Hack Nerd Font:h24")
  (let-g neovide_cursor_vfx_mode "ripple"))

(when (vim.fn.exists _G.neovide)
  (neovide-setting))

{}
