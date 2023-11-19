(import-macros {: epi : unless } :util.macros)
(import-macros {: async-do!} :kaza.macros)
(local {: timeout : async-fn : async-f } (require :kaza.cmd))
(local a (require :async))

;; load auttocmd before start


;; load setting lazily
(fn p-req [name]
  (let [(ok err) (pcall require name)]
    (unless ok
      (print (string.format "Can't loading module : %s. Err: %s" name err)))))

(local task-load (λ []
              (a.sync (λ []
                        (local req-lib (λ [lib]
                              (p-req (.. :core. lib))))
                        (req-lib :au)
                        (local async-preq (async-f req-lib))
                        (a.wait_all [((a.wrap (async-preq :gui)))
                                     ((a.wrap (async-preq :map)))
                                     ((a.wrap (async-preq :cmd)))
                                     ((a.wrap (async-preq :lsp)))])))))
((task-load))


;; load plugins lazily
(macro lplug [file_name]
  `(vim.cmd (.. "source ~/.config/nvim/plug/" ,file_name)))
(timeout 200
         (lambda []
           (vim.cmd "doautocmd User plug-lazy-load")
           (require :ime)
           (require :map)
           (lplug :command.vim)
           (lplug :terminal.vim)))

