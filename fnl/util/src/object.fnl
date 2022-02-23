(local l (require  :util.src.list))
(local ta (require :util.src.table1))

;; ref about lua metatable
;; https://inzkyk.xyz/lua_5_4/basic_concepts/metatables_and_metamethods/

;;; helper

(fn metatable-join [obj table]
  (let [metatable (or (getmetatable obj) {})]
    (each [key value (pairs table)]
      (tset metatable key value)) metatable))

(fn metable-detach [obj table]
  (let [metatable (or (getmetatable obj) {})]
    (each [key value (pairs table)]
      (table.remove metatable key))))

(fn metatalbe-add! [obj table]
  (setmetatable obj (metatable-join obj table)))

(fn metatable-remove! [obj table]
  (setmetatable obj (metable-detach obj table)))

(fn getmetadata [obj key]
  (let [metatable (or (getmetatable obj) {})]
    (. metatable key)))

;;; object

(local object {})

;;; deep copy

(fn object.deepcopy [org]
  (var copy {})
  (if (= (type org) :table)
    (do
      (each [key value (pairs org)]
        (tset copy (object.deepcopy key) (object.deepcopy value)))
      (setmetatable copy (object.deepcopy (getmetatable org))))
    (set copy org))
  copy)

;;; object its self

(fn object.prototype [self]
  self)

(fn object.new [self name]
  (let [obj {}]
    (metatalbe-add! obj {:__name name})
    (metatalbe-add! obj {:__self self})
    (tset obj :new nil)
    (tset obj :override nil)
    obj))

;;; will be used out side of `object`

(fn object.override [self name new]
  (let [obj (object.deepcopy self)]
    (metatalbe-add! obj {:__index self})
    (metatalbe-add! obj {:__name name})
    (tset obj :new new)
    obj))

;; extend prototype object
(fn object.extend* [self class]
  (let [object (object.deepcopy self)
        object (ta.join object class)] object))

;; actual extend
(fn object.extend [self name data]
  (let [obj (object.deepcopy self)
        obj (ta.join obj data)]
    (metatalbe-add! obj {:__name name})
    object))

;; this enable users declare new function without touching metadata.
(fn object.extend-new [self f]
  (let [obj (object.deepcopy self)]
    (tset obj :new (-> self.new f))))

;; not only actual OOP extend but also extend new function
;; make a function such that enables users write extend-new and extend at same time.
(fn object.class [self name data new]
  (let [obj (object.deepcopy self)
        obj (ta.join obj data)]
    (metatalbe-add! obj {:__name name})
    ;; TODO: make new `option`
    (tset obj :new (-> self.new new))))

(fn object.super [self]
  (getmetatable self :__index))

;;; test

; (local ob (object:new :hoge))
; (local ob1 (object.extend ob {:name :huga}))
; (l.dump (getmetatable ob))
;
; (l.dump ob)
;
; (l.dump ob1)
;
; (l.dump (getmetatable nil))
;
; (l.dump (getmetadata ob1 :__name))

object
