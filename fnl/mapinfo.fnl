(local map_register {
  :i {}
  :get_i (fn [self] self.i)
  :set_i (fn [self key command description]
          (tset self.i key [command description]))
  :n {}
  :get_n (fn [self] self.n)
  :set_n (fn [self key command description ]
          (tset self.n key [command description]))})

(map_register:set_i "hoge" "huga" "hog")
(print (vim.inspect (map_register:get_i)))
; (global keys map_register)
