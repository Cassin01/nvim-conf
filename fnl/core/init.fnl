(each [_ key (ipairs [:pack :au :opt :gui :map])]
  (require (.. :core :. key)))
