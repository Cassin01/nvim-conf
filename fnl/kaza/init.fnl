;;;; -- kaza (香気) --
;;;;   a zest variant for hotpot

(fn setup []
  (set _G.__kaza
       {:keymap {}
        :v {}
        :prefix {}
        :f {}}))

(fn u-cmd [name f ?opt]
       (let [opt (or ?opt {})]
         (tset opt :force true)
         (vim.api.nvim_create_user_command name f opt)))

{: setup
 : u-cmd}
