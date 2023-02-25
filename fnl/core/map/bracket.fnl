(import-macros {: def} :util.macros)
(local {: getline : col : line : indent : feedkeys} vim.fn)
(local {: foldl : map : range} (require :util.list))
(local {:keys-into-list keys :vals-into-list vals} (require :util.table1))
(local {: concat-with} (require :util.string))
(local {: rt} (require :kaza.map))
(local {: nvim_set_keymap} vim.api)
; (local right-brackets {"{" "}" "(" ")" "[" "]" "<" ">"})
(local right-brackets {"{" "}" "(" ")" "[" "]"})

(def in-front-of-the-cursor [char] [:string :boolean]
  "Whether word exist in front of the cursor"
  (let [line (getline :.)]
    (= (vim.fn.match line char (- (col :.) 1) 1) (- (col :.) 1))))

(def complete-decider [] [:boolean]
  "Return true when ...
  - There is [right bracket | white space] in front of the cursor.
  - There is no another word in front of the cursor. <- WARN: I think this is not I aimed
  - There is '$' in front of the cursor."
  (foldl (λ [seed char] (or seed (in-front-of-the-cursor char)))
         (or (not (in-front-of-the-cursor :.))
             (in-front-of-the-cursor "\\$"))
         [" " (unpack (vals right-brackets))]))

(def bracket-completion-default [left-bracket] [:string :function]
  (λ []
    (if (complete-decider)
      (.. left-bracket (. right-brackets left-bracket) (rt :<left>))
      left-bracket)))

(def bracket-completion-cr [key] [:string :function]
  (λ []
    (let [tabs (table.concat (map (λ [_] " ") (range (+ (indent (line :.)) vim.o.tabstop))))]
      (.. key (. right-brackets key) (rt :<left><cr><cr><up>) tabs))))

(def bracket-completion-space [key] [:string :function]
  (λ []
    (.. key (. right-brackets key) (rt :<left><space><space><left>))))

(def setup [] [:nil]
  (each [_ key (ipairs (keys right-brackets))]
    (let [pair (.. key (. right-brackets key))]
      (nvim_set_keymap :i pair (.. pair :<left>) {:noremap true
                                                  :silent true
                                                  :desc "move cursor to center of the pair"}))
    (nvim_set_keymap :i
                     key
                     ""
                     {:callback (bracket-completion-default key)
                      :noremap true
                      :silent true
                      :expr true
                      :desc "bracket completion default"})
    (nvim_set_keymap :i
                     (.. key "<enter>")
                     ""
                     {:callback (bracket-completion-cr key)
                      :noremap true
                      :silent true
                      :expr true
                      :desc "bracket completion cr"})
    (nvim_set_keymap :i
                     (.. key "<space>")
                     ""
                     {:callback (bracket-completion-space key)
                      :noremap true
                      :silent true
                      :expr true
                      :desc "bracket completion space"}))
  ; (nvim_set_keymap :i
  ;                  (.. "[" "<C-[>")
  ;                  "<esc>"
  ;                  {:noremap true
  ;                   :nowait true
  ;                   :desc "escape bracket completion"
  ;                   :silent true})
  )

{: setup}
