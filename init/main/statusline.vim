scriptencoding utf-8

set statusline=
set statusline+=%#DiffAdd#%{(mode()=='n')?'\ \ NORMAL\ ':''}      " or DiffAdd
set statusline+=%#function#%{(mode()=='i')?'\ \ INSERT\ ':''}    " or DiffChange
set statusline+=%#DiffDelete#%{(mode()=='r')?'\ \ RPLACE\ ':''}
set statusline+=%#Cursor#%{(mode()=='v')?'\ \ VISUAL\ ':''}
set statusline+=%*
"set statusline+=%#Visual#
set statusline+=%{&paste?'\ PASTE\ ':''}
set statusline+=%{&spell?'\ SPELL\ ':''}
"set statusline+=%#CursorIM#
set statusline+=%R
set statusline+=%m
"set statusline+=%#Cursor#
"set statusline+=%#CursorLine#
"set statusline+=%*
set statusline+=\ %t
set statusline+=%=
"set statusline+=%#CursorLine#
set statusline+=%{&fileencoding}
set statusline+=
set statusline+=\ \ %Y
"set statusline+=\ %#CursorIM#
set statusline+=\ %3l:%-2c
"set statusline+=\ %#Cursor#
set statusline+=\ %3p%%\ \ 
