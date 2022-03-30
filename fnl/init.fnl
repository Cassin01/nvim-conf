(if (= _G._kaza nil)
  (let [kaza (require :kaza)]
    (kaza.setup)))

(require :core)
