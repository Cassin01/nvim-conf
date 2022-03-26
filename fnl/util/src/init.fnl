(local list* (require (.. ... ".list")))
(local table* (require (.. ... ".table1")))
(local object* (require (.. ... ".object")))
(local type* (require (.. ... ".type")))
(local string* (require (.. ... ".string")))

(local M {})

(tset M :list list*)
(tset M :table table*)
(tset M :object object*)
(tset M :string string*)
(tset M :type type*)

M
