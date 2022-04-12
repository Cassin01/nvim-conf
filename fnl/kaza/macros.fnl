(local M {})

(fn M.set-option [k v]
  `(set ,(sym (.. "vim.o." (tostring k))) ,v))

(fn M.let-global [k v]
  "set 'k' to 'v' on vim.g table"
  `(tset vim.g ,(tostring k) ,v))

(fn M.use+ [name opt]
  "add disable option to use"
  `(when (not (-?> ,opt (. :disable)))
     (tset ,opt 1 name)
     (use ,opt)))

;;; common stuff

(fn M.ui-ignore-filetype []
  ["" :prompt :dashboard :help :nerdtree :TelescopePrompt])

;;; syntax sugar

(fn M.la [body]
  `(λ [] ,body))

;;; mapping

(fn M.cmd [s] (string.format "<cmd>%s<cr>" s))

(fn M.plug [s]
  (string.format "<Plug>%s" s))

(fn M.space [?s]
  (if (= ?s nil)
    :<space>
    (string.format "<space>%s" ?s)))

(fn M.br [c rest] (let [br ["[" "]"]]
                     (if (= c :l)
                       (.. (. br 1) rest)
                       (.. (. br 2) rest))))

(fn M.nmaps [prefix desc tbl]
  `(let [prefix# ((. (require :kaza.map) :prefix-o) :n ,prefix ,desc)]
     (each [_# l# (ipairs ,tbl)]
       (if (= (type (. l# 2)) :string)
         (prefix#.map (unpack l#))
         (prefix#.map-f (unpack l#))))))

;;; autocmd

(fn M.au [group event body ?opt]
  `(let [opt# {:callback (λ [] ,body)
               :group (vim.api.nvim_create_augroup ,group {:clear true})}]
     (each [k# v# (pairs (or ,?opt {}))]
       (tset opt# k# v#))
     (vim.api.nvim_create_autocmd ,event opt#)))

M
