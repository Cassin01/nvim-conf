(import-macros {: epi : unless } :util.macros)
(import-macros {: async-do!} :kaza.macros)
(local {: async-fn} (require :kaza.cmd))
(local a (require :async))
(local {: async-f} (require :kaza.async))

(fn p-req [name]
  (let [(ok err) (pcall require name)]
    (unless ok
      (err (string.format "Can't loading module : %s. Err: %s" name err)))))

; (epi _ key [:pack :au :opt :gui]
;        (p-req (.. :core. key)))

; (epi _ key [:map :cmd :lsp]
;      (async-do! (p-req (.. :core. key))))

(local task-load (λ []
              (a.sync (λ []
                        (local req-lib (λ [lib]
                              (p-req (.. :core. lib))))
                        (local async-preq (async-f req-lib))
                        (req-lib :pack)
                        (req-lib :au)
                        (req-lib :opt)
                        (a.wait_all [((a.wrap (async-preq :gui)))
                                     ((a.wrap (async-preq :map)))
                                     ((a.wrap (async-preq :cmd)))
                                     ((a.wrap (async-preq :lsp)))]))
                      )))
((task-load))

; (require :core.map)

; (local emacs-key-source (require :emacs-key-source))
; (each [k v (pairs {:<c-s> :inc-search
;                    :<c-g> :goto-line
;                    :<c-u> :relative-jump
;                    :<c-k> :retrive_till_tail
;                    :<c-s-k> :retrive_first_half })]
;   (vim.api.nvim_set_keymap :i k "" {:callback (. emacs-key-source v)
;                                     :noremap true
;                                     :silent true
;                                     :desc v}))
