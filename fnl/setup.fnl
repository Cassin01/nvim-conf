(if (= _G.__kaza nil)
  (let [kaza (require :kaza)]
    (kaza.setup)))

(require :core)
