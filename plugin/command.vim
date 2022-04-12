" search
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
