scriptencoding utf-8

"--------------------
" insert mode
"--------------------

inoremap <silent><C-b> <right>
inoremap <silent><C-k> <up>
inoremap <silent><C-l> <down>

" ---- 括弧補完 ----
inoremap (( (
inoremap {{ {
inoremap [[ [
inoremap ( ()<left>
inoremap { {}<left>
inoremap [ []<left>

" 例外処理: の後に続けて)を押したとき
inoremap <expr> )  strpart(getline('.'), col('.')-1, 1) == ")" ? "\<Right>" : ")"
inoremap <expr> ]  strpart(getline('.'), col('.')-1, 1) == "]" ? "\<Right>" : "]"
inoremap <expr> }  strpart(getline('.'), col('.')-1, 1) == "}" ? "\<Right>" : "}"
" ------------------

" quotation補完
inoremap " ""<left>
inoremap ' ''<left>

augroup FolowFile
    au!
    au BufRead,BufNewFile *.c    :call s:set_c_cpp()
    au BufRead,BufNewFile *.cpp  :call s:set_c_cpp()
    au BufRead,BufNewFile *.rs   :call s:set_rs()
    au BufRead,BufNewFile *.py   :call s:set_py()
    au BufRead,BufNewFile *.vim  :call s:set_vim()
    au BufRead,BufNewFile *.dart :call s:indent()
    au BufRead,BufNewFile *.go   :call s:indent()
    au BufRead,BufNewFile *.css  :call s:indent()
    au BufRead,BufNewFile *.js   :call s:indent()
    au BufRead,BufNewFile *.php  :call s:indent()
    au BufRead,BufNewFile *.html :call s:indent()
    au FileType c,cpp,cs,java,rust setlocal commentstring=//\ %s
		au FileType apache,python setlocal commentstring=#\ %s
augroup END

function! s:set_c_cpp()
    call s:indent()
    call s:comment()
    setlocal foldmethod=indent
endfunction

function! s:set_rs()
    call s:indent()
    call s:comment()
    setlocal foldmethod=indent
endfunction

function! s:set_py()
    setlocal foldmethod=indent
endfunction

function! s:set_vim()
    setlocal foldmethod=indent
endfunction

function! s:indent()
    inoremap {<enter> {}<left><cr><cr><up><tab>
endfunction

function! s:comment()
    inoremap /* <kDivide><kMultiply><space>
        \<space><kMultiply><kDivide>
        \<left><left><left>
endfunction

"--------------------
" terminal mode
"--------------------
"
tnoremap <silent> <esc> <C-\><C-n>

augroup FolowTerm
    au!
    au TermOpen * setlocal nonumber
augroup END
