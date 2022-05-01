(import-macros {: epi : ref-f} :util.macros)
(import-macros {: au! : nmaps : cmd : la : space} :kaza.macros)
(local {: u-cmd} (require :kaza))
(local {: bmap} (require :kaza.map))
(local evil-maps (require :core.map.veil.data))

(fn setup []
  (if vim.g.veil-global
    (epi _ k evil-maps (ref-f :map :kaza.map (unpack k)))))

(fn set-maps []
  (epi _ k evil-maps (bmap 0 (unpack k))))

(fn del-maps []
  (epi _ k evil-maps (vim.api.nvim_buf_del_keymap 0 (. k 1) (. k 2))))

(u-cmd
  :EvilEnable
  (λ [] (set-maps)
    (print "EvilMode Enabled")))

(u-cmd
  :EvilDisable
  (λ [] (del-maps)
    (print "EvilMode Disabled")))

(au! :evil :BufWinEnter (set-maps))

(nmaps (space :v)
       :veil
       [[:e (la (set-maps)) :enable]
        [:d (la (del-maps)) :disable]])

{: setup}
