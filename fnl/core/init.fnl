(import-macros {: epi : unless } :util.macros)
(import-macros {: async-do!} :kaza.macros)
(local {: async-fn : async-f } (require :kaza.cmd))
(local a (require :async))
; (local {: async-f} (require :kaza.async))

(fn p-req [name]
  (let [(ok err) (pcall require name)]
    (unless ok
      (print (string.format "Can't loading module : %s. Err: %s" name err)))))

(local task-load (λ []
              (a.sync (λ []
                        (local req-lib (λ [lib]
                              (p-req (.. :core. lib))))
                        (local async-preq (async-f req-lib))
                        (req-lib :pack)
                        (req-lib :au)
                        (req-lib :opt)
                        (a.wait_all [((a.wrap (async-preq :gui)))
                                     ((a.wrap (async-preq :map)))
                                     ((a.wrap (async-preq :cmd)))
                                     ((a.wrap (async-preq :lsp)))])))))
((task-load))

; (local req-lib (λ [lib]
;     (p-req (.. :core. lib))))
; (req-lib :pack)
; (req-lib :au)
; (req-lib :au)
; (req-lib :opt)
; (req-lib :gui)
; (req-lib :map)
; (req-lib :cmd)
; (req-lib :lsp)
