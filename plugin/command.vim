function! Retrive_till_tail()
let [text_before, text_after] = s:split_line()
if len(text_after) == 0
    normal! J
else
    call setline(line('.'), text_before)
endif
return ''
endfunction

function! s:split_line()
let line_text = getline(line('.'))
let text_after  = line_text[col('.')-1 :]
let text_before = (col('.') > 1) ? line_text[: col('.')-2] : ''
return [text_before, text_after]
endfunction

" " Command line {{{
" " move current directory (emacs C-f) {{{
" " https://vim-jp.org/vim-users-jp/2009/09/08/Hack-69.html
" command! -nargs=? -complete=dir CD  call s:ChangeCurrentDir('<args>')
" function! s:ChangeCurrentDir(directory)
" if a:directory == ''
"     lcd %:p:h
" else
"     execute 'lcd' . a:directory
" endif

" if exists("g:NERDTree")
"     exe "normal \<Plug>NerdTreeCWD"
" endif
" endfunction
" " }}}
" " }}}

" Dump the output of internal vim command into buffer
" ref: https://vi.stackexchange.com/questions/8378/dump-the-output-of-internal-vim-command-into-buffer
" command! -nargs=+ -complete=command Redir let s:reg = @@ | redir @"> | silent execute <q-args> | redir END | new | pu | 1,2d_ | let @@ = s:reg

" Visual mode {{{
" search {{{
function! s:VSetSearch()
let temp = @@
norm! gvy
let  @/ = '\V' . substitute(escape(@@, '\'), '\n', '\\n', 'g')
let @@ = temp
endfunction

" 下方向
vnoremap * :<C-u>call <SID>VSetSearch()<CR>//<CR><C-o>
" 上方向
vnoremap # :<C-u>call <SID>VSetSearch()<CR>??<CR><C-o>
" }}}
" }}}
