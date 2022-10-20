(import-macros {: cmd : nmaps : au!} :kaza.macros)
(import-macros {: req-f : when-let} :util.macros)
(local {: lazy : timeout : async-fn} (require :kaza.cmd))

;; TEMP
; For osx bigsur bug
; Issue: [Luarocks fails to install on macOS BigSur #180](https://github.com/wbthomason/packer.nvim/issues/180)
; (if (vim.fn.has :mac)
;   (vim.fn.setenv "MACOSX_DEPLOYMENT_TARGET" "10.15"))

(vim.cmd "packadd packer.nvim")
((-> (require :packer) (. :startup))
 (λ []
   (use [:wbthomason/packer.nvim
         {1 :rktjmp/hotpot.nvim
          :config (λ []
                    (nmaps
                      :<space>c
                      "packer hotpot"
                      [[:cc (cmd :PackerCompile) :compile {:silent false}]
                       [:i (cmd :PackerInstall) :install {:silent false}]
                       [:sy (cmd :PackerSync) :sync {:silent false}]
                       [:st (cmd :PackerStatus) :status {:silent false}]
                       [:cb (cmd "lua print(require('hotpot.api.compile')['compile-buffer'](0))") "compile and print buffer" {:silent false}]
                       [:eb (cmd "lua print(require('hotpot.api.eval')['eval-buffer'](0))") "evaluate and print buffer" {:silent false}]
                       [:r (λ []
                             (let [cache_path_fn (. (require :hotpot.api.cache) :cache-path-for-fnl-file)
                                   fnl-file (vim.fn.expand :%:p)
                                   lua-file (cache_path_fn fnl-file)]
                               (if lua-file
                                 (vim.cmd (.. ":new " lua-file))
                                 (print "No matching cache file for current file")))) "open cached lua file" {:silent false}]])
                    ((req-f :setup :hotpot) {:compiler {:modules {:correlate false}}})
                    )}
         ; :lewis6991/impatient.nvim
         ])
   (use (require :core.pack.plugs))
   (use_rocks :luasocket)
   ; (use_rocks :Lua-cURL)
   ))

;; load plugins lazily
(macro lplug [file_name]
  `(vim.cmd (.. "source ~/.config/nvim/plug/" ,file_name)))
(timeout 200 
         (lambda []
           (vim.cmd "doautocmd User plug-lazy-load")
           (lplug :command.vim)
           (lplug :hyper_witch.vim)
           (lplug :terminal.vim)))

