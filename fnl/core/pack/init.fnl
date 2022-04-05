(vim.cmd "packadd packer.nvim")

;;; TEMP
; This code for bigsur bug
; Issue: [Luarocks fails to install on macOS BigSur #180](https://github.com/wbthomason/packer.nvim/issues/180)
(if (vim.fn.has :mac)
  (vim.fn.setenv "MACOSX_DEPLOYMENT_TARGET" "10.15"))

((-> (require :packer) (. :startup))
 (λ []
   (use {1 :wbthomason/packer.nvim})
   (use :rktjmp/hotpot.nvim)
   (use (require :core.pack.plugs))
   (use_rocks :luasocket)))
