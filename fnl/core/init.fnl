(import-macros {: epi : unless } :util.macros)
(import-macros {: async-do!} :kaza.macros)
(local {: async-fn} (require :kaza.cmd))


(fn p-req [name]
  (let [(ok err) (pcall require name)]
    (unless ok
      (err (string.format "Can't loading module : %s. Err: %s" name err)))))

(epi _ key [:pack :au :opt]
       (p-req (.. :core :. key)))

(epi _ key [:gui :map :cmd :lsp]
     (async-do! (p-req (.. :core. key))))
