(local {: concat-with} (require :util.src.list))
 
(tset package :path
      (concat-with ";"
                   package.path
                   "./?.lua"
                   "/Users/cassin/.config/nvim/lua5.1/share/lua/5.1/?.lua"
                   "/Users/cassin/.config/nvim/lua5.1/share/lua/5.1/?/init.lua"))

(vim.cmd "packadd packer.nvim")

((. (require :packer) :startup)
 (λ []
   (use "wbthomason/packer.nvim")
   (each [_ plug (ipairs (require :core.pack.plugs))]
     (use plug))))
