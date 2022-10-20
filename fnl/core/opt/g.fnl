(local {: execute-cmd} (require :kaza.file))
{
; :python3_host_prog (. (execute-cmd "which python") 1)
:python3_host_prog (vim.fn.expand "~/.pyenv/shims/python3")
:polyglot_disabled [:markdown :fennel]
; :colors_name :kanagawa
:colors_name :habamax
; :colors_name :tokyonight
:markdown_fenced_languages [:python :ruby :javascript :js=javascript
                            :json=javascript :vim :css :ocaml
                            :rust
                            :haskell]

:terminal_color_0  :#2e3436
:terminal_color_1  :#cc0000
:terminal_color_2  :#4e9a06
:terminal_color_3  :#c4a000
:terminal_color_4  :#3465a4
:terminal_color_5  :#75507b
:terminal_color_6  :#0b939b
:terminal_color_7  :#d3d7cf
:terminal_color_8  :#555753
:terminal_color_9  :#ef2929
:terminal_color_10 :#8ae234
:terminal_color_11 :#fce94f
:terminal_color_12 :#729fcf
:terminal_color_13 :#ad7fa8
:terminal_color_14 :#00f5e9
:terminal_color_15 :#eeeeec

:loaded_gzip              1
:loaded_tar               1
:loaded_tarPlugin         1
:loaded_zip               1
:loaded_zipPlugin         1
:loaded_rrhelper          1
:loaded_2html_plugin      1
:loaded_vimball           1
:loaded_vimballPlugin     1
:loaded_getscript         1
:loaded_getscriptPlugin   1
:loaded_netrw             1
:loaded_netrwPlugin       1
:loaded_netrwSettings     1
:loaded_netrwFileHandlers 1
:loaded_matchit           1
}
