((. (require :kaza) :setup))

(each [_ key (ipairs [:pack :opt :gui :map :au])]
  (require (.. :core :. key)))
