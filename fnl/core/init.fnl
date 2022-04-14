(import-macros {: epi : unless } :util.macros)
(epi _ key [:pack :au :opt :gui :map :cmd]
     (let [(ok err) (pcall require (.. :core :. key))]
       (unless ok
         (error (string.format "Can't loading module: %s. ERR: %s" key err)))))

;;; plugins
(epi _ key []
     (let [(ok err) (pcall require (.. :plug. key))]
       (unless ok
         (error (string.format "Can't loading module: %s. ERR: %s" key err)))))
