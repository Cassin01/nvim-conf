scriptencoding utf-8

" insert mode {{{
    " Using Default key bindings {{{
    " Reference:
    " https://qiita.com/kentarosasaki/items/785d8c1e1c4433df6ac9

    if has("mac")
lua << EOF
    -- require('init')
    -- 移動
    keys:set_map_i('π', '<up>', '<opt-p>: up')
    keys:set_map_i('˜', '<down>', '<opt-n>: down')
    keys:set_map_i('ƒ', '<right>', '<opt-f>: right')
    keys:set_map_i('∫', '<left>', '<opt-b>: left')
    keys:set_map_i('´', '<end>', '<opt-e>: jump to EOL')
    keys:set_map_i('å', '<C-o>:call To_head_of_line()<CR>', '<opt-a>: jump to BOL')
    keys:set_map_i('Ï', '<esc>ea', '<shift><opt-f> move forward one word')
    keys:set_map_i('ı', '<esc>bi', '<shift><opt-b> move to one word later')
    keys:set_map_i('∆', '<esc>o', '<opt-j> insert new line bellow and jump')
    keys:set_map_i('ø', '<esc>O', '<opt-o> insert new line above and jump' )

    -- copy & paste
    keys:set_map_i('˚', '<C-r>=Retrive_till_tail()<CR>', '<opt-k>: delete from cursor to EOL')
    keys:set_map_i('∂', '<Del>', '<opt-d>: Delete (delete a char at the back of cursor)')
    keys:set_map_i('˙', '<c-h>', '<opt-h>: backspace (delete a char at the front of cursor)')
    keys:set_map_i('€', '<c-o>v', '<opt-@>: mark the start point of yank')
    keys:set_map_v('∑', 'y`]i', '<opt-w>: yank')
    keys:set_map_v('„', 'x`]i', '<opt-w>: delete and yankk')
    keys:set_map_i('¥', '<esc>pa', '<opt>y: paste')

    -- undo & redo
    keys:set_map_i('—', '<esc>ua', '<opt-->: undo')
    keys:set_map_i('±', '<esc><c-r>a', '<opt-+>: redo')

    -- window
    keys:set_map_i('≈0', '<c-o><c-w>q', '<opt-x>0: close a window')
    keys:set_map_i('≈2', '<c-o>:<c-u>vs<cr>', '<opt-x>2; split-vertically')
    keys:set_map_i('≈3', '<c-o>:<c-u>sp<cr>', '<opt-x>3: split-horizontally')
    keys:set_map_i('≈o', '<c-o><c-w>w', '<opt-x>o: move to other windows')

    -- file
    keys:set_map_i('≈ß', '<c-o>:w<cr>', '<opt-x><opt-s>: save-file')
EOF

" 情報を表示
" inoremap <silent>  <c-o>:lua keys:show_i()<cr>

" floating window
" ref: https://qiita.com/delphinus/items/a202d0724a388f6cdbc3
function! s:search_selected_key()
    let l:keys_dict = luaeval('keys:get_i()')
    let l:selected = split(getline('.'), ',')[0]
    for k in keys(l:keys_dict)
        if k . ' ' . l:keys_dict[k] == l:selected
            execute  "quit"
            let l:command ="normal a" . k
            execute l:command
            startinsert
            return
        endif
    endfor
    echom 'command is not founded'
    execute  "quit"
endfunction

" 先頭から比較して含まれてたらtureを返す
function! s:incremental_search(str, txt)
    if strlen(a:str) > strlen(a:txt)
        return v:false
    endif

    for l:i in range(0, strlen(a:str)-1)
        if a:str[l:i] != a:txt[l:i]
            return v:false
        endif
    endfor

    return v:true
endfunction

    else
        " enter digraph
        inoremap <silent><C-k> <up>

        " same as <cr>
        inoremap <silent><C-j> <down>

        " 'c-f insert the character which is below the cursor'
        inoremap <silent><C-f> <right>

        " 'c-e insert the character which is below the cursor'
        " -> カーソルを行の末尾に移動
        inoremap <silent><C-e> <END>

        " 'c-a insert previously inserted text'
        " -> カーソルを行の先頭へ移動
        inoremap <silent><C-a> <C-o>:call To_head_of_line()<CR>

        " 現在のカーソル位置から行末尾までを切り取り
        inoremap <silent><C-l> <C-r>=Retrive_till_tail()<CR>

        " delete one shiftwidth of indent in the current line
        "" -> カーソルの右の文字を削除
        inoremap <C-d> <Del>

        inoremap <silent><C-b> <left>
    endif

    function! To_head_of_line()
        let start_column = col('.')
        normal! ^
        if col('.') == start_column
            normal! 0
        endif
        return ''
    endfunction

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
    " }}}

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
            call s:set_texlike_math()
            if has_key(g:plugs, 'vim-auto-save')
                let g:auto_save = 1
            endif
        endfunction

        function! s:set_haskell()
        endfunction

        function! s:set_lisp()
            setlocal shiftwidth=2
        endfunction

        function! s:set_ros()
        endfunction

        function! s:set_markdown()
            set nofoldenable    " disable folding
            call s:set_texlike_math()
        endfunction

        function! s:set_texlike_math()
            inoremap $<enter> $$$$<left><left><cr><cr><up>
            "inoremap $$       $$<left>
            inoremap $$ $$<left>
        endfunction

        "function! s:indent()
        "    inoremap {<enter> {}<left><cr><cr><up><tab>
        "endfunction

        function! s:comment()
            inoremap /* <kDivide><kMultiply><space>
                \<space><kMultiply><kDivide>
                \<left><left><left>
        endfunction

        function! s:bracket_helper()
            let f1 = match(getline('.'), '.', col('.')-1, 1)!=col('.')-1
            let f2 = match(getline('.'), ' ', col('.')-1, 1) == col('.')-1
            let f3 = match(getline('.'), ')', col('.')-1, 1) == col('.')-1
            let f4 = match(getline('.'), ']', col('.')-1, 1) == col('.')-1
            let f5 = match(getline('.'), '}', col('.')-1, 1) == col('.')-1
            return f1 || f2 || f3 || f4 || f5
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
                    " カーソルの後ろに文字がない
                    " または空白文字があるときに閉じ括弧を補完
                    if s:bracket_helper()
                        return "{}\<left>"
                    else
                        return "{"
                    endif
                endfunction
                inoremap <expr> { <SID>curly_bracket_completion2()
            " }}}
            inoremap {{{ {{{
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
                " カーソルの後ろに文字がない
                " または空白文字があるときに閉じ括弧を補完
                " またはカッコがある時
                if s:bracket_helper()
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

" Dump the output of internal vim command into buffer
" ref: https://vi.stackexchange.com/questions/8378/dump-the-output-of-internal-vim-command-into-buffer
command! -nargs=+ -complete=command Redir let s:reg = @@ | redir @"> | silent execute <q-args> | redir END | new | pu | 1,2d_ | let @@ = s:reg


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
