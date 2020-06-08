scriptencoding utf-8

" insert mode {{{
    inoremap <silent><C-b> <right>
    inoremap <silent><C-k> <up>
    inoremap <silent><C-l> <down>
    " 括弧補完 {{{
        inoremap (( (
        inoremap {{ {
        inoremap [[ [
        inoremap "" "
        inoremap '' '
        inoremap ( ()<left>
        inoremap { {}<left>
        inoremap [ []<left>

        " 例外処理: の後に続けて)を押したとき
        inoremap <expr> )  strpart(getline('.'), col('.')-1, 1) == ")" ? "\<Right>" : ")"
        inoremap <expr> ]  strpart(getline('.'), col('.')-1, 1) == "]" ? "\<Right>" : "]"
        inoremap <expr> }  strpart(getline('.'), col('.')-1, 1) == "}" ? "\<Right>" : "}"
    " }}}

    " quotation補完 {{{
        inoremap " ""<left>
        inoremap ' ''<left>
    " }}}

    " Language {{{
        augroup FolowFile
            au!
            au BufRead,BufNewFile *.c    :call s:set_c_cpp()
            au BufRead,BufNewFile *.h    :call s:set_c_cpp()
            au BufRead,BufNewFile *.cpp  :call s:set_c_cpp()
            au BufRead,BufNewFile *.rs   :call s:set_rs()
            au BufRead,BufNewFile *.py   :call s:set_py()
            au BufRead,BufNewFile *.vim  :call s:set_vim()
            au BufRead,BufNewFile *.tex  :call s:set_tex()
            au BufRead,BufNewFile *.hs   :call s:set_haskell()
            au BufRead,BufNewFile *.md   :call s:set_markdown()
            au BufRead,BufNewFile *.dart :call s:indent()
            au BufRead,BufNewFile *.go   :call s:indent()
            au BufRead,BufNewFile *.css  :call s:indent()
            au BufRead,BufNewFile *.js   :call s:indent()
            au BufRead,BufNewFile *.php  :call s:indent()
            au BufRead,BufNewFile *.html :call s:indent()
            au BufRead,BufNewFile *.java :call s:indent()
            au FileType c,cpp,cs,java,rust setlocal commentstring=//\ %s
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
            setlocal foldmethod=marker
        endfunction

        function! s:set_tex()
            "tex ギリシャ文字可視化無効
            let g:tex_conceal = ''
        endfunction

        function! s:set_haskell()
            let g:rainbow_active=1
              let w:m3 = matchadd("Haskell03", '(')
              let w:m3 = matchadd("Haskell03", '(')
              let w:m3 = matchadd("Haskell03", ')')
              let w:m3 = matchadd("Haskell03", ')')
              "let w:m3 = matchadd("Haskell04", '$')
              "let w:m3 = matchadd("Haskell04", '$')
        endfunction

        function! s:set_markdown()
            inoremap [ [
        endfunction

        function! s:indent()
            inoremap {<enter> {}<left><cr><cr><up><tab>
        endfunction

        function! s:comment()
            inoremap /* <kDivide><kMultiply><space>
                \<space><kMultiply><kDivide>
                \<left><left><left>
        endfunction
    " }}}
" }}}

" Terminal mode {{{
    tnoremap <silent> <esc> <C-\><C-n>

    augroup FolowTerm
        au!
        au TermOpen * setlocal nonumber
    augroup END
" }}}

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
