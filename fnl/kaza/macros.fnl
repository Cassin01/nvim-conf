;;; nivm/embedded.fnl

(import-macros m :util.src.macros)

(local M {})

(fn _encode [s]
  "convert characters of string 's' to byte_"
  (if (= (type s) :string)
    `,(.. "_" (string.gsub s "." (fn [KAZA_C#] (.. (string.byte KAZA_C#) "_"))))
    `(.. "_" (string.gsub ,s "." (fn [KAZA_C#] (.. (string.byte KAZA_C#) "_"))))))

(fn M.smart-concat [xs d]
  "concatenate only literal strings in seq 'xs'"
  (let [d (or d "")
        out [] ]
    (if (= (type xs) :string)
      ; simply pass literal strings through
      (table.insert out xs)
      (if (sym? xs)
        ; decide what to do with variables at runtime
        (table.insert out
          `(if (= (type ,xs) :string)
             ,xs
             (table.concat ,xs ,d)))
        ; do whatever we can at compile time
        (do
          (var last-string? false)
          (each [_ v (ipairs xs)]
            (let [string? (= (type v) :string)
                  len (length out)]
              (if (and last-string?
                       string?)
                (tset out len (.. (. out len) d v))
                (table.insert out v))
              (set last-string? string?))))))
    (if (= (length out) 1)
      (unpack out)
      (if (= d "")
        `(.. ,(unpack out))
        `(table.concat ,out ,d)))))

(fn _vlua [f kind id]
  "store function 'f' into _G._KAZA and return its v:lua"
  (if id
    `(let [KAZA_ID# ,(_encode id)]
       (tset _G._kaza ,kind KAZA_ID# ,f)
       (.. ,(.. "v:lua._kaza." kind ".") KAZA_ID#))
    `(let [KAZA_N# (. _G._kaza ,kind :#)
           KAZA_ID# (.. "_" KAZA_N#)]
       (tset _G._kaza ,kind KAZA_ID# ,f)
       (tset _G._kaza ,kind :# (+ KAZA_N# 1))
       (.. ,(.. "v:lua._kaza." kind ".") KAZA_ID#))))

;; ref: https://github.com/shaunsingh/nyoom.nvim/blob/main/fnl/conf/macros.fnl
(fn M.cmd [string]
  "execute vim command"
  `(vim.cmd ,string))


(fn _create-augroup [dirty? name ...]
  "define a new augroup, with without autocmd"
  (let [out []
        body (if ... `[(do ,...)] `[])
        opening (M.smart-concat ["augroup" name] " ")]
    `(do
       (vim.cmd ,opening)
       ,(when (not dirty?)
          `(vim.cmd "autocmd!"))
       ,(unpack body)
       (vim.cmd "augroup END"))))

(fn M.def-augroup [name ...]
  (_create-augroup false name ...))

(fn M.def-augroup-dirty [name ...]
  (_create-augroup true name ...))

(fn M.def-autocmd [events patterns ts]
  (let [events (M.smart-concat events ",")
        patterns (M.smart-concat patterns ",")
        command (M.smart-concat ["au " events " " patterns " " ts])]
    `(vim.cmd ,command)))

(fn M.def-autocmd-fn [events patterns ...]
  (let [events (M.smart-concat events ",")
        patterns (M.smart-concat patterns ",")
        vlua (_vlua `(fn [] ,...) :autocmd)
        vlua-sym (gensym :KAZA_VLUA)
        command (M.smart-concat ["autocmd " events " " patterns " :call " vlua-sym "()"])]
    `(let [,vlua-sym ,vlua]
       (vim.cmd ,command))))


(fn M.set-option [k v]
  `(set ,(sym (.. "vim.o." (tostring k))) ,v))

(fn M.let-global [k v]
  "set 'k' to 'v' on vim.g table"
  `(tset vim.g ,(tostring k) ,v))

M
