(local {: nr2char : getchar : feedkeys : getpos : setpos : cursor
        : getline : col : setline} vim.fn)

(local {: join} (require :util.src.table1))
(local {: deepcopy} (require :util.src.object))
;;; generate mini window
;;; {{{
(local window {})

(tset window :config {:relative "cursor"
                      :anchor "NW"
                      :style "minimal"
                      })


(fn window.start [self config]
  (local util (require :util.src))
  (local t util.talbe)
  (tset self :buf (vim.api.nvim_create_buf false true))
  (tset self :config (join self.config config))
  (tset self :win (vim.api.nvim_open_win self.buf 1 (deepcopy self.config)))
  (vim.api.nvim_win_set_option self.win "winblend" 10))

(fn window.buf_set_text [window]
  (vim.api.nvim_buf_set_text window.buf 0 0 0 0 ["¬"]))

(fn window.window_start [window]
  (local pos (getpos "."))
  (local c-row (. pos 2))
  (local c-col (. pos 3))
  (window.start window {:row c-row :col c-col :height 1  :width 1}))

(fn window.window_close [window]
  (vim.api.nvim_win_close window.win true))
;;; }}}

window
