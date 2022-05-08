(macro c [c ?s]
  (let [s (or ?s "")]
    (.. (string.format :<C-%s> c) s)))

{
 (c :a) (c :\ :a)
 (c :c) (c :\ :c)
 (c :o) (c :\ :o)
 (c :u) (c :\ :u)
 (c :d) (c :\ :d)
 (c :k) (c :\ :k)
 (c :t) (c :\ :t)
 (.. (c :x) (c :t)) (.. (c :\ :x) (c :t))
 }
