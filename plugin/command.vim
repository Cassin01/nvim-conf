" search
function! s:VSetSearch()
let temp = @@
norm! gvy
let  @/ = '\V' . substitute(escape(@@, '\'), '\n', '\\n', 'g')
let @@ = temp
endfunction

" up direction
vnoremap * :<C-u>call <SID>VSetSearch()<CR>//<CR><C-o>

" down direction
vnoremap # :<C-u>call <SID>VSetSearch()<CR>??<CR><C-o>
