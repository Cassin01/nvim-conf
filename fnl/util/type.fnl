(local M {})

(fn M.nil? [o]
  (= o nil))

(fn M.table? [o]
  (= (type o) :table))

(fn M.number? [o]
  (= (type o) :number))

(fn M.string? [o]
  (= (type o) :string))

M
