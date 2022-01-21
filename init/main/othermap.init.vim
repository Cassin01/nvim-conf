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
    keys:set_map_i('å', '<C-o>:call <SID>to_head_of_line()<CR>', '<opt-a>: jump to BOL')
    keys:set_map_i('Ï', '<esc>ea', '<shift><opt-f> move forward one word')
    keys:set_map_i('ı', '<esc>bi', '<shift><opt-b> move to one word later')


    -- copy & paste
    keys:set_map_i('˚', '<C-r>=<SID>retrive_till_tail()<CR>', '<opt-k>: delete from cursor to EOL')
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

function! s:add_spaces(str, num)
    let l:new_str = a:str
    for l:i in range(0, a:num)
        let l:new_str = l:new_str . ' '
    endfor
    return l:new_str
endfunction

function! s:trimer(str, till)
    let l:new_str = ""
    for l:i in range(0, len(a:str)-1)
        if l:i > a:till
            return l:new_str
        endif
        let l:new_str  = l:new_str . a:str[l:i]
    endfor
    return l:new_str
endfunction
function! s:formatter(matched, inputed_length)
    let l:formatted_lines = []
    for l:k in sort(keys(a:matched))
        call add(l:formatted_lines, '      ' . strcharpart(l:k, a:inputed_length, a:inputed_length+1) . ' → ' .  strpart(s:add_spaces(a:matched[l:k], 45)  , 0, 45) )
    endfor

    let s:split_num = &columns / 50

    let l:actuall_lines = []
    let l:i = 0
    let l:each_line = ""
    for l:k in l:formatted_lines
        let l:each_line = l:each_line . l:k
        let l:i =l:i + 1
        if l:i % s:split_num == 0
            call add(l:actuall_lines, l:each_line)
            let l:each_line = ""
        endif
    endfor
    return l:actuall_lines
endfunction

function! s:ceil(a, b)
    return  (a:a + a:b - 1) / a:b
endfunction

function! s:evil_witch_syntax()
    " https://github.com/liuchengxu/vim-which-key/tree/master/syntax
    if exists('b:current_syntax')
        finish
    endif
    let b:current_syntax = 'evil_witch'
    let s:sep = '→'
    execute 'syntax match WitchKeySeperator' '/'.s:sep.'/' 'contained'
    execute 'syntax match WitchKey' '/\(^\s*\|\s\{2,}\)\S.\{-}'.s:sep.'/' 'contains=WitchKeySeperator'
    syntax match WhichKeyGroup / +[0-9A-Za-z_/-]*/
    syntax region WhichKeyDesc start="^" end="$" contains=WitchKey, WitchKeyGroup, WitchKeySeperator

    highlight default link WitchKey          Function
    highlight default link WitchKeySeperator DiffAdded
    highlight default link WitchKeyGroup     Keyword
    highlight default link WitchKeyDesc      Identifier
endfunction

function! s:listen_commands()
    redraw!
    setlocal filetype=evil_witch

    let l:keys_dict = luaeval('keys:get_i()')
    let l:inputted_st = ""
    while v:true
        let l:c = ""
        if getchar(1)
            let l:c = getchar()
        else
            continue
        endif
        let l:inputted_st = l:inputted_st . nr2char(l:c)
        let l:matched = filter(l:keys_dict, {key, _ -> s:incremental_search(l:inputted_st, key)})

        " call nvim_buf_set_lines(s:buf, 0, -1, v:true, values(map(l:matched, {key, val -> key . ' ' . val})))
        call nvim_buf_set_lines(s:buf, 0, -1, v:true, s:formatter(l:matched, strchars(l:inputted_st)))
        " echom values(map(l:matched, {key, val -> key . ' ' . val}))

        let l:line_size = s:ceil(len(values(map(l:matched, {key, val -> key . ' ' . val}))), s:split_num)+1
        " call nvim_win_set_height(s:win, line_size)
        let s:opts.height=line_size
        let s:opts.row = &lines-line_size-s:row_offset
        call nvim_win_set_config(s:win, s:opts)
        redraw!

        if len(l:matched) == 1
            return l:matched
        endif
        if len(l:matched) == 0
            return l:matched
        endif
    endwhile
endfunction

function! s:key_selecter()
    let l:matched = s:listen_commands()
    if len(l:matched) == 1
        let l:command = "normal a" . keys(l:matched)[0]
        execute "quit"
        try
            execute l:command
        catch /error!/
            echom "err occured"
        endtry
        startinsert
    else
        execute "quit"
        startinsert
    endif
endfunction

function! s:escape()
    execute "quit"
    startinsert
endfunction

function! s:key_window()
    let s:buf = nvim_create_buf(v:false, v:true)
    " call nvim_buf_set_lines(s:buf, 0, 0, v:true, luaeval('keys:get_info()') )

    let l:keys_dict = luaeval('keys:get_i()')
    call nvim_buf_set_lines(s:buf, 0, 0, v:true, s:formatter(l:keys_dict, 0))
    " let opts = {'relative': 'cursor', 'width': 30, 'height': 15, 'col': 0,
    "             \ 'row': 1, 'anchor': 'NW', 'style': 'minimal'}

    let s:row_offset = &cmdheight + (&laststatus > 0 ? 1 : 0)
    let s:opts = {'relative': 'win', 'height': nvim_buf_line_count(s:buf), 'col': 0,
                \ 'row': &lines-nvim_buf_line_count(s:buf)-s:row_offset, 'anchor': 'NW', 'style': 'minimal'}
    let s:opts.width = &columns - s:opts.col

    let s:win = nvim_open_win(s:buf, 1, s:opts)

    " optional: change highlight, otherwise Pmenu is used
    call nvim_win_set_option(s:win, 'winhl', 'Normal:Pmenu')

    call s:evil_witch_syntax()

    " 疑似的に半透明にする
    call nvim_win_set_option(s:win, 'winblend', 60)

    " command! KeyWindowE call s:search_selected_key()
    " nnoremap <buffer> <silent> ,d :KeyWindowE<CR>
    " command! SelecteE call s:key_selecter()
    " nnoremap <buffer> <silent> <space> :SelecteE<CR>
    command! WichESC call s:escape()
    nnoremap <buffer> <silent> <esc> :WichESC<CR>
    call s:key_selecter()
endfunction

command! KeyWindow :call s:key_window()
nnoremap <silent> ,d :KeyWindow<CR>
inoremap <silent>  <esc>:KeyWindow<cr>

        " " p
        " inoremap <silent>π <up>

        " " n
        " inoremap <silent>˜ <down>

        " " f
        " inoremap <silent>ƒ <right>

        " " b
        " inoremap <silent>∫ <left>

        " " e: 行末
        " inoremap <silent>´ <END>

        " " a: 行頭
        " inoremap <silent>å <C-o>:call <SID>to_head_of_line()<CR>

        " " k: 現在のカーソル位置から行末尾までを切り取り
        " inoremap <silent>˚ <C-r>=<SID>retrive_till_tail()<CR>

        " " d: Delete カーソルの後ろを削除
        " inoremap <silent>∂ <Del>

        " " h: backspace カーソルの前を削除
        " inoremap <silent>˙ <c-h>

        " " y: 貼り付け
        " inoremap <silent>¥ <esc>pa

        " " shift+option+f 1単語前に移動
        " inoremap <silent>Ï <esc>ea

        " " shift+option+b 1単語後に移動
        " inoremap <silent>ı <esc>bi

        " " -: undo
        " inoremap <silent>— <esc>ua

        " " +: redo
        " inoremap <silent>± <esc><c-r>a
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
        inoremap <silent><C-a> <C-o>:call <SID>to_head_of_line()<CR>

        " 現在のカーソル位置から行末尾までを切り取り
        inoremap <silent><C-l> <C-r>=<SID>retrive_till_tail()<CR>

        " delete one shiftwidth of indent in the current line
        "" -> カーソルの右の文字を削除
        inoremap <C-d> <Del>

        inoremap <silent><C-b> <left>
    endif

    function! s:to_head_of_line()
        let start_column = col('.')
        normal! ^
        if col('.') == start_column
            normal! 0
        endif
        return ''
    endfunction

    function! s:retrive_till_tail()
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

"     " Show current IME status on cursor color. {{{
" augroup IMEInsert
"     autocmd InsertCharPre * :call s:currentIME()
" augroup END
" let s:script_dir = fnamemodify(resolve(expand('<sfile>', ':p')), ':h')
" function! s:currentIME()
" py3 << EOF
" import vim
" script_dir = vim.eval('s:script_dir')
" sys.path.insert(0, script_dir)
" import ime
" vim.command("let s:ime_result = %d" % int(ime.current_ime()))
" EOF
" let s:capstatus = system('xset -q | grep "Caps Lock" | awk ''{print $4}''')
" if s:capstatus[0:-2] == 'on'
"     echom 'called'
"     highlight iCursor guibg=#8F1D21
"     set guicursor+=i:ver25-iCursor
" elseif s:ime_result == 0
"     highlight iCursor guibg=#cc6666
"     set guicursor+=i:ver25-iCursor
" else
"     highlight iCursor guibg=#5FAFFF
"     set guicursor+=i:ver25-iCursor
" endif
" endfunction
"     "}}}

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
            inoremap $$       $<space><space>$<left><left>
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
                    " カーソルの後ろに文字がない
                    " または空白文字があるときに閉じ括弧を補完
                    if matchstr(getline('.'), '.', col('.'), 1)==''
                        \ || match(getline('.'), ' ', col('.'), 1) >= 0
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
                    " カーソルの後ろに文字がない
                    " または空白文字があるときに閉じ括弧を補完
                    if matchstr(getline('.'), '.', col('.'), 1)==''
                        \ || match(getline('.'), ' ', col('.'), 1) >= 0
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
