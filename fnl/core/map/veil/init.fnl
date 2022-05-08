(import-macros {: epi : ref-f : unless} :util.macros)
(import-macros {: au! : nmaps : la : space} :kaza.macros)
(local {: u-cmd} (require :kaza))
(local veil-maps (require :core.map.veil.data))
(local built-in-maps (require :core.map.veil.built-in))

(fn _integrate-default-maps [m]
  (var ret m)
  (epi _ k m
    (let [alter-cmd (. built-in-maps (. k 3))]
      (unless (= alter-cmd nil)
        (table.insert ret [0 :i alter-cmd (. k 3) {:noremap true :silent true :desc (. k 3)}]))))
  ret)

(fn setup [?opt]
  (local opt (or ?opt []))
  (local  bmap (. opt :bmap))
  (fn _set-maps [m]
    (local actual-maps (_integrate-default-maps m))
    (lambda []
      (epi _ k actual-maps
           (vim.api.nvim_buf_set_keymap (unpack k)))))

  (local set-maps (if (= bmap nil)
                    (_set-maps veil-maps)
                    (_set-maps bmap)))

    (fn del-maps []
      (epi _ k veil-maps (vim.api.nvim_buf_del_keymap (. k 1) (. k 2) (. k 3))))

    (u-cmd
      :VeilEnable
      (λ [] (set-maps)
        (print "VeilMode Enabled")))

    (u-cmd
      :VeilDisable
      (λ [] (del-maps)
        (print "VeilMode Disabled")))

    (nmaps (space :v)
           :veil
           [[:e (la (set-maps)) :enable]
            [:d (la (del-maps)) :disable]])

    (au! :veil :BufWinEnter (set-maps)))

; (fn set-maps []
;   ; (epi _ k veil-maps (bmap 0 (unpack k)))
;   (epi _ k veil-maps
;        (vim.api.nvim_buf_set_keymap (unpack k))
;        (let [alter-cmd (. built-in-maps (. k 3))]
;          (unless (= alter-cmd nil)
;            (vim.api.nvim_buf_set_keymap 0 :i (. k 3) alter-cmd {:noremap true :silent true :desc (. k 3)})))))

; (fn del-maps []
;   (epi _ k veil-maps (vim.api.nvim_buf_del_keymap 0 (. k 1) (. k 2))))

; (u-cmd
;   :VeilEnable
;   (λ [] (set-maps)
;     (print "VeilMode Enabled")))

; (u-cmd
;   :VeilDisable
;   (λ [] (del-maps)
;     (print "VeilMode Disabled")))



{: setup}
