(local M {})

(fn M.set-o [k v]
  `(set ,(sym (.. "vim.o." (tostring k))) ,v))

(fn M.let-g [k v]
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

(fn M.la [...]
  `(λ [] ,...))

;;; mapping

(fn M.cmd [s] (string.format "<cmd>%s<cr>" s))

(fn M.plug [s]
  (string.format "<Plug>%s" s))

(fn M.space [?s]
  (if (= ?s nil)
    :<Space>
    (string.format "<Space>%s" ?s)))

(fn M.br [c ?rest] (let [br ["[" "]"]
                        rest (or ?rest "")]
                     (if (= c :l)
                       (.. (. br 1) rest)
                       (.. (. br 2) rest))))

(fn M.nmaps [prefix desc tbl]
  `(let [prefix# ((. (require :kaza.map) :prefix-o) :n ,prefix ,desc)]
     (each [_# l# (ipairs ,tbl)]
       (if (= (type (. l# 2)) :string)
         (prefix#.map (unpack l#))
         (prefix#.map-f (unpack l#))))))

(fn M.map [mode key cmd desc]
  `(let [map# (. (require :kaza.map) :map)]
     (map# ,mode ,key ,cmd ,desc)))

;;; autocmd
(fn _group_handler [group]
  `(if
     (= (type ,group) :string)
     (vim.api.nvim_create_augroup ,group {:clear true})
     (= (type ,group) :number)
     ,group
     (print "au: group must be number or string" ,group)))

(fn _callback [group event body ?opt]
  `(let [opt# {:callback (λ [] ,body)
               :group ,(_group_handler group)}]
     (each [k# v# (pairs (or ,?opt {}))]
       (tset opt# k# v#))
     (vim.api.nvim_create_autocmd ,event opt#)))

(fn _command [group event command ?opt]
  `(let [opt# {:command ,command
               :group ,(_group_handler group)}]
     (each [k# v# (pairs (or ,?opt {}))]
       (tset opt# k# v#))
     (vim.api.nvim_create_autocmd ,event opt#)))

(fn M.au! [group event body ?opt]
  (if
    (= (type body) :table) (_callback group event body ?opt)
    (= (type body) :string) (_command group event body ?opt)
    (assert-compile false "au: body must be a sequence or string" body)))

(fn M.async-do! [body]
  `(do
     (var async# nil)
     (set async#
          (vim.loop.new_async
            (vim.schedule_wrap
                  (λ []
                    ,body
                    (async#:close)))))
     (async#:send)))

M
