scriptencoding utf-8

" insert mode {{{
    inoremap <silent><C-b> <right>
    inoremap <silent><C-k> <up>
    inoremap <silent><C-l> <down>
    " 括弧補完 {{{
        inoremap () ()<left>
        inoremap {} {}<left>
        inoremap [] []<left>

        " 例外処理: の後に続けて)を押したとき
        " inoremap <expr> )  strpart(getline('.'), col('.')-1, 1) == ")" ? "\<Right>" : ")"
        " inoremap <expr> ]  strpart(getline('.'), col('.')-1, 1) == "]" ? "\<Right>" : "]"
        " inoremap <expr> }  strpart(getline('.'), col('.')-1, 1) == "}" ? "\<Right>" : "}"
    " }}}

    " quotation補完 {{{
        inoremap "" ""<left>
        inoremap '' ''<left>
    " }}}

    " Language FIXME: colorの方で呼ばれるので呼ばれない {{{
        " augroup FlowWriteFile
        "     autocmd BufWrite *    :call s:w_set_default()
        "     autocmd BufWrite *.md :call s:w_set_markdown()
        " augroup END

        " function! s:w_set_default()
        "     " if exists(':CocDisable')
        "     "     CocDisable
        "     " else
        "     "     echom 'Err: CocDisable is not exists (at othermap.init.vim)'
        "     " endif

        "     if exists('g:auto_save')
        "         let g:auto_save = 0
        "     else
        "         echom 'g:auto_save is not exists (at othermap.init.vim)'
        "     endif
        " endfunction

        " function! s:w_set_markdown()
        "     if exists('g:auto_save')
        "         let g:auto_save = 1
        "     else
        "         echom 'g:auto_save is not exists (at othermap.init.vim)'
        "     endif

        "     if &conceallevel != 0
        "         setlocal conceallevel=0
        "     endif
        " endfunction


        augroup FolowFile
            au!
            au BufRead,BufNewFile *      :call s:set_default()
            au BufRead,BufNewFile *.c    :call s:set_c_cpp()
            au BufRead,BufNewFile *.h    :call s:set_c_cpp()
            au BufRead,BufNewFile *.cpp  :call s:set_c_cpp()
            au BufRead,BufNewFile *.rs   :call s:set_rs()
            au BufRead,BufNewFile *.py   :call s:set_py()
            au BufRead,BufNewFile *.vim  :call s:set_vim()
            au BufRead,BufNewFile *.tex  :call s:set_tex()
            au BufRead,BufNewFile *.hs   :call s:set_haskell()
            au BufRead,BufNewFile *.lisp :call s:set_lisp()
            au BufRead,BufNewFile *.ros  :call s:set_ros()
            au BufRead,BufNewFile *.md   :call s:set_markdown()
            "au BufRead,BufNewFile *.dart :call s:indent()
            "au BufRead,BufNewFile *.go   :call s:indent()
            "au BufRead,BufNewFile *.css  :call s:indent()
            "au BufRead,BufNewFile *.js   :call s:indent()
            "au BufRead,BufNewFile *.ts   :call s:indent()
            "au BufRead,BufNewFile *.php  :call s:indent()
            "au BufRead,BufNewFile *.html :call s:indent()
            "au BufRead,BufNewFile *.java :call s:indent()
            "au BufRead,BufNewFile *.bib  :call s:indent()
        augroup END

        function! s:set_default()
        endfunction

        function! s:set_c_cpp()
            setlocal commentstring=//\ %s
            "call s:indent()
            call s:comment()
            setlocal foldmethod=indent
        endfunction

        function! s:set_rs()
            setlocal commentstring=//\ %s
            "call s:indent()
            call s:comment()
            setlocal foldmethod=indent
        endfunction

        function! s:set_py()
            setlocal foldmethod=indent
        endfunction

        function! s:set_vim()
            setlocal foldmethod=marker
            inoremap " "
        endfunction

        function! s:set_tex()
            "tex ギリシャ文字可視化無効
            let g:tex_conceal = ''
            inoremap $$  $$<left>
        endfunction

        function! s:set_haskell()
        endfunction

        function! s:set_lisp()
             setlocal shiftwidth=2
        endfunction

        function! s:set_ros()
        endfunction

        function! s:set_markdown()
            inoremap $<enter> $$$$<left><left><cr><cr><up>
            inoremap $$       $$<left>
            set nofoldenable    " disable folding
        endfunction


        "function! s:indent()
        "    inoremap {<enter> {}<left><cr><cr><up><tab>
        "endfunction

        function! s:comment()
            inoremap /* <kDivide><kMultiply><space>
                \<space><kMultiply><kDivide>
                \<left><left><left>
        endfunction

        " 波括弧補完 {{{
            " 改行補完 {{{
            " indentについて: http://psy.swansea.ac.uk/staff/carter/Vim/vim_indent.html
                function! s:curly_bracket_completion1()
                    let l:tabs = join(map(range(1, indent(line(".")) + &tabstop), {_index, _val -> " "}), '')
                    return "{}\<left>\<cr>\<cr>\<up>" . l:tabs
                endfunction
                inoremap <expr> {<enter> <SID>curly_bracket_completion1()
            " }}}

            " 閉じ括弧補完 {{{
                function! s:curly_bracket_completion2()
                    "カーソルの後ろに文字がなければ閉じ括弧を補完
                    if matchstr(getline('.'), '.', col('.')-1, 1)==''
                        return "{}\<left>"
                    else
                        return "{"
                    endif
                endfunction
                inoremap <expr> { <SID>curly_bracket_completion2()
            " }}}
        " }}}
        " 括弧補完 {{{
            " 改行補完 {{{
            " indentについて: http://psy.swansea.ac.uk/staff/carter/Vim/vim_indent.html
                function! s:bracket_completion1()
                    let l:tabs = join(map(range(1, indent(line(".")) + &tabstop), {_index, _val -> " "}), '')
                    return "()\<left>\<cr>\<cr>\<up>" . l:tabs
                endfunction
                inoremap <expr> (<enter> <SID>bracket_completion1()
            " }}}

            " 閉じ括弧補完 {{{
                function! s:bracket_completion2()
                    "カーソルの後ろに文字がなければ閉じ括弧を補完
                    if matchstr(getline('.'), '.', col('.')-1, 1)==''
                        return "()\<left>"
                    else
                        return "("
                    endif
                endfunction
                inoremap <expr> ( <SID>bracket_completion2()
            " }}}
        " }}}
    " }}}
" }}}

" Terminal mode {{{
    tnoremap <silent> <esc> <C-\><C-n>

    augroup FolowTerm
        au!
        au TermOpen * setlocal nonumber
    augroup END
" }}}

" Command line {{{
    " move current directory (emacs C-f) {{{
    " https://vim-jp.org/vim-users-jp/2009/09/08/Hack-69.html
    command! -nargs=? -complete=dir CD  call s:ChangeCurrentDir('<args>')
    function! s:ChangeCurrentDir(directory)
        if a:directory == ''
            lcd %:p:h
        else
            execute 'lcd' . a:directory
        endif

        if exists("g:NERDTree")
            exe "normal \<Plug>NerdTreeCWD"
        endif
    endfunction
    " }}}
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
