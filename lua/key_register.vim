" Evil Witch {{{
" 情報を表示
" inoremap <silent>  <c-o>:lua keys:show_i()<cr>
" floating window
" ref: https://qiita.com/delphinus/items/a202d0724a388f6cdbc3
function! s:search_selected_key()
    let l:keys_dict = luaeval('keys:get_i()') " MARK
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

function! s:on_matched(key)
    let l:command = "normal a" . a:key
    try
        execute l:command
    catch /error!/
        echom "err occured"
    endtry
endfunction

function! s:after_quit()
    startinsert
endfunction

function! s:key_selecter() " MARK
    let l:matched = s:listen_commands()
    if len(l:matched) == 1
        execute "quit"
        call s:on_matched(keys(l:matched)[0])
        call s:after_quit()
        " let l:command = "normal a" . keys(l:matched)[0]
        " execute "quit"
        " try
        "     execute l:command
        " catch /error!/
        "     echom "err occured"
        " endtry
        " startinsert
    else
        execute "quit"
        call s:after_quit()
    endif
endfunction

function! s:escape()
    execute "quit"
    startinsert
endfunction

function! s:key_window()
    let s:buf = nvim_create_buf(v:false, v:true)
    " call nvim_buf_set_lines(s:buf, 0, 0, v:true, luaeval('keys:get_info()') )

    let l:keys_dict = luaeval('keys:get_i()') " MARK
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
    call nvim_win_set_option(s:win, 'winblend', 10)

    " command! KeyWindowE call s:search_selected_key()
    " nnoremap <buffer> <silent> ,d :KeyWindowE<CR>
    " command! SelecteE call s:key_selecter()
    " nnoremap <buffer> <silent> <space> :SelecteE<CR>
    command! WichESC call s:escape()
    nnoremap <buffer> <silent> <esc> :WichESC<CR>
    call s:key_selecter() " MARK
endfunction

command! KeyWindow :call s:key_window()
nnoremap <silent> ,d :KeyWindow<CR>
inoremap <silent>  <esc>:KeyWindow<cr>
" }}}
