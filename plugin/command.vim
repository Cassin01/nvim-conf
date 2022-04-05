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
