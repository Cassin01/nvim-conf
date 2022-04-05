(vim.cmd "packadd packer.nvim")

((-> (require :packer) (. :startup))
 (λ []
   (use {1 :wbthomason/packer.nvim :opt true})
   (use :rktjmp/hotpot.nvim)
   ;(use (require :core.pack.plugs))
   (each [_ k (ipairs (require :core.pack.plugs))]
     (use k))))
