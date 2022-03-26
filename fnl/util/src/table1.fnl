(local l (require :util.src.list))

(local M {})

(fn M.keys-into-list [tbl]
        "`keys()`"
        (var lst [])
        (each [key value (pairs tbl)]
                (table.insert lst key)) lst)
(fn M.vals-into-list [tbl]
        "`vals()`"
        (var lst [])
        (each [key value (pairs tbl)]
                (table.insert lst value)) lst)

(fn M.join [tbl1 tbl2]
        "join two tables"
        (each [key value (pairs tbl2)]
                (tset tbl1 key value)) tbl1)

(fn M.in? [x tbl]
        "Wether x in tbl or not"
        (let [lst (M.keys-into-list tbl)]
                (l.in? x lst)))

M
