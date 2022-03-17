((. (require :kaza) :setup))

(each [_ key (ipairs [:pack :opt :gui :playground :map :au])]
  (require (.. :core :. key)))
