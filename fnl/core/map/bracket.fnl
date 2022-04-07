(import-macros {: def} :util.src.macros)
(local {: getline : col : line : indent : feedkeys} vim.fn)
(local {: foldl : map : range} (require :util.src.list))
(local {:keys-into-list keys :vals-into-list vals} (require :util.src.table1))
(local {: concat-with} (require :util.src.string))
(local {: rt} (require :kaza.map))
(local {: nvim_set_keymap} vim.api)
(local right-brackets {"{" "}" "(" ")" "[" "]"})

(def in-front-of-the-cursor [char] [:string :boolean]
  "Whether word exist in front of the cursor"
  (let [line (getline :.)]
    (= (vim.fn.match line char (- (col :.) 1) 1) (- (col :.) 1))))

(def complete-decider [] [:boolean]
  "Return true when ...
  - There is [right bracket | white space] in front of the cursor.
  - There is no another word in front of cursor."
  (foldl (λ [seed char] (or seed (in-front-of-the-cursor char)))
         (not (in-front-of-the-cursor :.)) [" " (unpack (vals right-brackets))]))

(def bracket-completion-default [left-bracket] [:string :function]
  (λ []
    (if (complete-decider)
      (.. left-bracket (. right-brackets left-bracket) (rt :<left>))
      left-bracket)))

(def bracket-completion-cr [key] [:string :function]
  (λ []
    (let [tabs (table.concat (map (λ [_] " ") (range (+ (indent (line :.)) vim.o.tabstop))))]
      (.. key (. right-brackets key) (rt :<left><cr><cr><up>) tabs))))

(def setup [] [:nil]
  (each [_ key (ipairs (keys right-brackets))]
    (tset (. _G.__kaza :f) (.. :bracket_completion_default_ (string.byte key)) (bracket-completion-default key) )
    (tset (. _G.__kaza :f) (.. :bracket_completion_cr_ (string.byte key)) (bracket-completion-cr key))
    (let [pair (.. key (. right-brackets key))]
      (nvim_set_keymap :i pair (.. pair :<left>) {:noremap true
                                                  :silent true
                                                  :desc "move cursor to center of the pair"}))
    (nvim_set_keymap :i
                     key
                     (.. :v:lua.__kaza.f.bracket_completion_default_ (string.byte key) "()")
                     {:noremap true
                      :silent true
                      :expr true
                      :desc "bracket completion default"})
    (nvim_set_keymap :i
                     (.. key "<enter>")
                     (.. :v:lua.__kaza.f.bracket_completion_cr_ (string.byte key) "()")
                     {:noremap true
                      :silent true
                      :expr true
                      :desc "bracket completiion cr"})))

{: setup}
