; TODO erase me
;(local (module-name file-name) ...)
;(fn empty? [s]
;  (or (= s nil) (= s "")))
;(local list (require (if (empty? module-name)
;               :list
;               :util.src.list)))

(local M {})

(fn M.empty? [s]
  (or (= s nil) (= s "")))

(fn M.concat-with [d ...]
  (table.concat [...] d))

;;; ref: https://github.com/Olical/aniseed/blob/master/fnl/aniseed/string.fnl
(fn M.triml [s]
  (string.gsub s "^%s*(.-)" "%1"))

(fn M.trimr [s]
  (string.gsub s "(.-)%s*$" "%1"))

(fn M.trim [s]
  (string.gsub s "^%s*(.-)%s*$" "%1"))

;;; ref: https://notabug.org/nuclearkev/lispy-fennel/src/master/str.fnl
(fn M.take [s ind]
  "return s of substring 1 ~ ind "
  (string.sub s 1 ind))

(fn M.drop [s ind]
  "return s of substring ind ~ `end of string`"
  (string.sub s ind))

(fn M.split [s by]
  "split `s` by `by`"
  (var current s)
  (var tbl-of-strings [])
  (var spliting? true)
  (while spliting?
    (var (start end) (string.find current by))
    (if start
      (do (table.insert tbl-of-strings (M.take current (- start 1)))
        (set current (M.drop current (+ end 1))))
      (do (table.insert tbl-of-strings current)
        (set spliting? false))))
  tbl-of-strings)

M
