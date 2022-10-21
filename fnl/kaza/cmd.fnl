; (local uv (require :luv))
(local uv vim.loop)
(local {: concat-with} (require :util.list))

;;; run a vim command asynchronously.
; (fn async-cmd [cmd]
;   (local timer (uv.new_timer))
;   (timer:start 1000 0
;                (vim.schedule_wrap
;                  (λ []
;                    ; (print :Awake!)
;                    (vim.cmd cmd)
;                    (timer:close))))
;   ; (print :Sleeping)

;   ;; uv.run will block and wait for all events to run.
;   ;; when there are not longer any active handles, it will return
;   (uv.run))

(fn async-f [f]
  (λ [...]
    (local args [...])
    (λ [callback]
      (var async nil)
      (set async
           (uv.new_async
             (vim.schedule_wrap
               (λ []
                 (if (= args nil)
                   (f)
                   (f (unpack args)))
                 (callback)
                 (async:close)))))
      (async:send))))

(fn async-cmd [cmd]
  (var async nil)
  (set async
       (uv.new_async
         (vim.schedule_wrap
           (λ []
             (vim.cmd cmd)
             (async:close)))))
  (async:send))

(fn async-fn [callback]
  (var async nil)
  (set async
       (uv.new_async
         (vim.schedule_wrap
           (λ []
             (callback)
             (async:close)))))
  (async:send))

(fn timeout [ms callback]
                 (local timer (uv.new_timer))
                 (local callback (vim.schedule_wrap (lambda []
                                                      (uv.timer_stop timer)
                                                      (uv.close timer)
                                                      (callback))))
                 (uv.timer_start timer ms 0 callback))

(fn lazy [ms callback]
  (async-fn (lambda []
              (timeout ms callback))))

(fn syntax [group pat ...]
  (vim.cmd (concat-with " " :syntax :match group pat ...)))


;;; run a vim command asynchronously.
; (fn async-test []
;   (local timer (uv.new_timer))
;   (timer:start 1000 0
;                (vim.schedule_wrap
;                  (λ []
;                    (print :Awake!)

;                    (vim.cmd (.. "echom nvim_exec(\'GInfo" :M "\', v:true)"))
;                    (print 1)
;                    (vim.cmd (.. "echom nvim_exec(\'GInfo" :F "\', v:true)"))
;                    (print 2)
;                    (vim.cmd (.. "echom nvim_exec(\'GInfo" :W "\', v:true)"))
;                    (print 3)
;                    (vim.cmd (.. "echom nvim_exec(\'GInfo" :C "\', v:true)"))
;                    (print 4)

;                    (timer:close))))
;   (print :Sleeping)

;   ;; uv.run will block and wait for all events to run.
;   ;; when there are not longer any active handles, it will return
;   (uv.run))


{: async-cmd
 : async-fn
 : timeout
 : syntax
 : lazy
 : async-f
 ; : async-test
 }
