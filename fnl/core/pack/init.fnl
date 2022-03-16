(local {: concat-with} (require :util.src.list))
(local {: nvim-home} (require :kaza.file))

(tset package :path
      (concat-with ";"
                   package.path
                   "./?.lua"
                   (concat-with "/" (nvim-home) "lua5.1/share/lua/5.1/?.lua")
                   (concat-with "/" (nvim-home) "lua5.1/share/lua/5.1/?/init.lua")))

(vim.cmd "packadd packer.nvim")

(vim.cmd "autocmd BufWritePost plugs.fnl PackerCompile")

((. (require :packer) :startup)
 (λ []
   (use {1 "wbthomason/packer.nvim" :opt true})
   (use "rktjmp/hotpot.nvim")
   (each [_ plug (ipairs (require :core.pack.plugs))]
     (use plug))))
