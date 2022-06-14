(local vf vim.fn)
(fn show [str]
  (if (not= str nil)
    (print str)))
(fn out_cb [job_id data event]
  (show (. data 2)))
(fn start [cmd]
  (vf.jobstart ["curl" "-d" cmd "localhost:11111"]
               {:on_stdout out_cb }))

{: start}
