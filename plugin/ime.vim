scriptencoding utf-8

" https://zenn.dev/kawarimidoll/articles/cf6caaa7602239
" {{{
command! -nargs=+ -complete=highlight MergeHighlight call s:MergeHighlight(<q-args>)
function! s:MergeHighlight(args) abort
  let l:args = split(a:args)
  if len(l:args) < 2
    echoerr '[MergeHighlight] At least 2 arguments are required.'
    echoerr 'New highlight name and source highlight names.'
    return
  endif

  " skip 'links' and 'cleared'
  execute 'highlight' l:args[0] l:args[1:]
      \ ->map({_, val -> substitute(execute('highlight ' . val),  '^\S\+\s\+xxx\s', '', '')})
      \ ->filter({_, val -> val !~? '^links to' && val !=? 'cleared'})
      \ ->join()
endfunction
" }}}


let s:ime_kind = {}
let s:ime_kind['caps'] = 0
let s:ime_kind['kana'] = 1
let s:ime_kind['skk'] = 2
let s:ime_kind['roman'] = 3
let s:current_status = s:ime_kind['roman']

" Show current IME status on cursor color. {{{
function! s:currentIME(timer)
py3 << EOF
import vim
import plistlib
from pathlib import Path

HIRIGANA="com.apple.inputmethod.Japanese"
KATANA="com.apple.inputmethod.Japanese.Katakana"
ROMAN="com.apple.inputmethod.Roman"

def current_ime():
    home = Path.home()
    str_plist_path = ('Library/Preferences/com.apple.HIToolbox.plist')
    path = Path(str_plist_path)
    with open(home / path, 'rb') as fp:
        pl = plistlib.load(fp)

    if len(pl["AppleSelectedInputSources"]) == 2:
        ime = pl["AppleSelectedInputSources"][1]['Input Mode']
        if ime == ROMAN:
            return 1
        else:
            return 0
    else: # have not been reflected on the file. I treat as NOT ROMAN
        # print(pl["AppleSelectedInputSources"])
        return 0

vim.command("let s:ime_result = %d" % int(current_ime()))
EOF


if 'i' == mode()
    let s:capstatus = system('xset -q | grep "Caps Lock" | awk ''{print $4}''')
    if s:capstatus[0:-2] == 'on'
        if s:current_status != s:ime_kind['caps']
            " caps red
            let s:current_status = s:ime_kind['caps']
            highlight iCursor guibg=#c94449 " or #8F1D21
            set guicursor=i:ver25-iCursor
        endif
    elseif skkeleton#mode() != ''
        if s:current_status != s:ime_kind['skk']
            " skkeleton mode
            let s:current_status = s:ime_kind['skk']
            MergeHighlight iCursor Cursor
            set guicursor=i:ver25-iCursor
        endif
    elseif   s:ime_result == 0
        if s:current_status != s:ime_kind['kana']
            " kana orange
            let s:current_status = s:ime_kind['kana']
            highlight iCursor guibg=#cc6666
            set guicursor=i:ver25-iCursor
        endif
    elseif s:ime_result == 1
        if s:current_status != s:ime_kind['roman']
            let s:current_status = s:ime_kind['roman']
            highlight iCursor guibg=#5FAFFF
            set guicursor=i:ver25-iCursor
        endif
    endif
endif
endfunction
    "}}}


" call timer_start(1500, function("s:currentIME"), {"repeat": -1})

"augroup IMEInsert
"    autocmd CursorHoldI,InsertCharPre * :call s:currentIME()
"augroup END
