(local util (require :util.src))
;(util.list.dump util)
(local ta util.table)
(local o util.object)

(local window {})

(tset window :config {:col 0 :relative "editor" :anchor "NW" :style "minimal" :border "rounded"})

(fn window.start [self config]
  (tset self :buf (vim.api.nvim_create_buf false true))
  (tset self :config (ta.join self.config config))
  (tset self :win (vim.api.nvim_open_win self.buf 1 (o.deepcopy self.config)))
  (vim.api.nvim_win_set_option self.win "winblend" 10))

(window.start window {:height 20 :row 3 :width 3})

(local socket (require "socket"))

;socket.sleep(sec)

;(print package.path)


 (vim.api.nvim_win_close window.win true)
;(util.list.dump util)

