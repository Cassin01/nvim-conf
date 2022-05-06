(import-macros {: epi : ref-f} :util.macros)
(import-macros {: au! : nmaps : cmd : la : space} :kaza.macros)
(local {: u-cmd} (require :kaza))
(local {: bmap} (require :kaza.map))
(local veil-maps (require :core.map.veil.data))

(fn setup []
  (if vim.g.veil-global
    (epi _ k veil-maps (ref-f :map :kaza.map (unpack k)))))

(fn set-maps []
  ; (print (.. (length veil-maps) "key binds integrated"))
  (epi _ k veil-maps (bmap 0 (unpack k))))

(fn del-maps []
  (epi _ k veil-maps (vim.api.nvim_buf_del_keymap 0 (. k 1) (. k 2))))

(u-cmd
  :VeilEnable
  (λ [] (set-maps)
    (print "VeilMode Enabled")))

(u-cmd
  :VeilDisable
  (λ [] (del-maps)
    (print "VeilMode Disabled")))

(au! :veil :BufWinEnter (set-maps))

(nmaps (space :v)
       :veil
       [[:e (la (set-maps)) :enable]
        [:d (la (del-maps)) :disable]])

{: setup}
