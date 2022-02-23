(local list* (require (.. ... ".list")))
(local table* (require (.. ... ".table1")))
(local object* (require (.. ... ".object")))
(local type* (require (.. ... ".type")))
(import-macros {:fn* fn-} :util.src.macros)

;;; test

; (m.fn* hoge2 {:a1 :string :b2 :string} (print a1))
;
; (hoge2 "hoge" "hoge")


(local M {})

(tset M :list list*)
(tset M :table table*)
(tset M :object object*)
(tset M :type type*)
(tset M :fn fn*)

M
