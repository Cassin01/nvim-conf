"" search
" REWRITE:
" @@ is same as @. So this code would be rewriten with vim.getreg('\"') and
" vim.setreg('"').
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


"" w3m
"
" REWRITE: This code will be rewrite into fennel when
" vim.api.nvim_create_user_command is available.
function! s:www(word) abort
execute('term w3m google.com/search\?q="' . a:word . '"')
endfunction

command! -nargs=1 WWW call s:www(<f-args>)
