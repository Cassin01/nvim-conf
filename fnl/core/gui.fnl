(import-macros
  {: set-o
   : let-g} :kaza.macros)

(fn neovide-setting []
  ; (tset vim.o :guifont "Hack Nerd Font:h16")
  (tset vim.o :guifont "Hack Nerd Font:h24")
  (let-g neovide_cursor_vfx_mode "ripple")
  (let-g neovide_cursor_antialiasing  true)
  (let-g neovide_transparency  0.5)
  (let-g neovide_no_idle  true)
  (let-g neovide_cursor_animation_length  0.13)
  (let-g neovide_cursor_vfx_particle_density  10.0)
  (let-g neovide_floating_blur_amount_x 2.0)
  (let-g neovide_floating_blur_amount_y 2.0)

  )

(when (vim.fn.exists _G.neovide)
  (neovide-setting))

{}
