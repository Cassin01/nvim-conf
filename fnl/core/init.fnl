(each [_ key (ipairs [:pack :au :opt :gui :map :cmd])]
  (require (.. :core :. key)))
