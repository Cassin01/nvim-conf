(local l (require :util.src.list))

(local M {})

(fn M.keys-into-list [tbl]
        (var lst [])
        (each [key value (pairs tbl)]
                (set lst (l.append lst key))) lst)
(fn M.vals-into-list [tbl]
        (var lst [])
        (each [key value (pairs tbl)]
                (set lst (l.append lst value))) lst)

(fn M.join [tbl1 tbl2]
        (each [key value (pairs tbl2)]
                (tset tbl1 key value)) tbl1)

(fn M.in? [x tbl]
        (let [lst (M.keys-into-list tbl)]
                (l.in? x lst)))

M
