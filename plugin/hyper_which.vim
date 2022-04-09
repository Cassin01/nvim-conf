" ---------------------------------------------------------
" Object
" https://mattn.kaoriya.net/software/vim/20070817164837.htm
" --------------------------------------------------------
" {{{
function! s:class_prototype() dict
    return self
endfunction

function! s:class_override(name, class_new) dict
    let class = deepcopy(self)
    let class.__name = a:name
    let class.new = a:class_new
    let class.__super = self
    return class
endfunction

function! s:class_extend(class) dict
    let class = deepcopy(self)
    let class = extend(class, a:class)
    return class
endfunction

function! s:class_new() dict
    let instance = deepcopy(self)
    call remove(instance, "new")
    call remove(instance, "override")
    let instance.__super = self
    return instance
endfunction

function! s:class_tostrting() dict
    return self.__name
endfunction

function! s:super() dict
    return self.__super
endfunction


let Object = #{
    \ __name: "Object",
    \ __super: {},
    \ prototype: function("s:class_prototype"),
    \ override: function("s:class_override"),
    \ extend : function("s:class_extend"),
    \ new: function("s:class_new"),
    \ super: function("s:super"),
    \ tostring: function("s:class_tostrting")}

" TEST
" if exists("object")|unlet object|endif
" let object = Object.New()
" echo object.tostring()
" }}}

" ---------------------------------------------------------
" key
" ---------------------------------------------------------
" {{{
function! s:get_i(self) dict
    return self.n
endfunction
function! s:new() dict
    let instance = deepcopy(self)
    let instance.n = {}
    let instance.get_i = function("s:get_i")
    let instance.new = function("s:key_new")
    return instance
endfunction
" }}}

" ---------------------------------------------------------
" Window
" ---------------------------------------------------------
" {{{
function! s:update_config(self, config) dict
    let self.config = extend(self.config, a:config)
    call nvim_win_set_config(self.win, self.config)
endfunction

function! s:window_start(self, config) dict
    let self.config = extend(self.config, a:config)
    let self.win = nvim_open_win(s:buf, 1, deepcopy(self.config))
    call nvim_win_set_option(self.win, 'winblend', 10)

endfunction

function! s:window_new() dict
    let instance = deepcopy(self)
    let instance.config = {
        \ 'col': 0,
        \ 'relative': "editor",
        \ 'anchor': 'NW',
        \ 'style': 'minimal',
        \ 'border': 'rounded',
        \ }
    let instance.new = function("s:window_new")
    let instance.start = function("s:window_start")
    let instance.update = function("s:update_config")
    return instance
endfunction
let Window = Object.override("Window", function("s:window_new"))
" }}}

" ---------------------------------------------------------
" Hyper Witch
" ---------------------------------------------------------
" {{{
" TODO:
" [x]: スペースキーの表示と入力
"   - 表示: ⎵
"   - 入力: スペース
" [ ]: タブキーの表示と入力
"   - 表示: ⇥
"   - 入力: タブ文字
"   INFO: どう実現するか
"       - view
"           - 入力されていない文字を^<tab> -> ⇥ する．
"       - 入力
"           - 9 が入力されて, かつ残りの文字が^<tab>であれば6文字進める.
" [x]: 入力が一方が短いとき決定できないバグ -> <cr>を押したら即時評価する

" global valuables {{{
" length mast be 1
let g:hwhich_char_tab = '⇥'
let g:hwhich_char_space = '⎵'
" }}}

" 先頭から比較して含まれてたらtureを返す
function! s:incremental_search(str, txt)
    if strlen(a:str) > strlen(a:txt)
        return v:false
    endif

    for l:i in range(0, strlen(a:str)-1)
        if a:str[l:i] !=# a:txt[l:i]
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

" View
" args
"   - inputted_length: the length of inputted characters
function! s:formatter(matched, inputted_length, column_size)
    let l:formatted_lines = []
    for l:k in sort(keys(a:matched))
        let l:k_tmp = substitute(l:k,' ' ,g:hwhich_char_space, 'g') " COMBAK
        let discription = strpart(s:add_spaces(a:matched[l:k], 45)  , 0, 45)
        call add(l:formatted_lines, '      ' . strcharpart(k_tmp,  a:inputted_length, 1) . ' → ' .  discription )
    endfor

    " 列の数
    let s:split_num = a:column_size / 50

    " 行の数
    let row_size = (len(l:formatted_lines) + s:split_num - 1) / s:split_num

    " View
    let row_counter = 0
    let l:actuall_lines = map(range(row_size), {-> ''})
    for formatted_line in l:formatted_lines
        let l:actuall_lines[row_counter] = l:actuall_lines[row_counter] . formatted_line
        let row_counter = row_counter + 1
        if row_counter % row_size == 0
            let row_counter = 0
        endif
    endfor
    return l:actuall_lines
endfunction

function! s:ceil(a, b)
    return  (a:a + a:b - 1) / a:b
endfunction

function! s:hyper_wich_syntax()
    " https://github.com/liuchengxu/vim-which-key/tree/master/syntax
    if exists('b:current_syntax')
        return
    endif
    let b:current_syntax = 'evil_witch'
    let s:sep = '→'
    call matchadd('WitchPrefix', '\[[a-z\-]*\]')
    execute 'syntax match WitchKeySeperator' '/'.s:sep.'/' 'contained'
    execute 'syntax match WitchKey' '/\(^\s*\|\s\{2,}\)\S.\{-}'.s:sep.'/' 'contains=WitchKeySeperator'
    syntax match WhichKeyGroup / +[0-9A-Za-z_/-]*/
    syntax region WhichKeyDesc start="^" end="$" contains=WitchKey, WitchKeyGroup, WitchKeySeperator

    highlight default link WitchKey          Function
    highlight default link WitchKeySeperator DiffAdded
    highlight default link WitchKeyGroup     Keyword
    highlight default link WitchKeyDesc      Identifier
    highlight default link WitchPrefix       Type
endfunction
" }}}

" ---------------------------------------------------------
" Hyper Witch methods
" ---------------------------------------------------------
"  {{{
function! s:key_converter_for_input(key_dict)
    let new_dict = {}
    for key in keys(a:key_dict)
        let new_key = substitute(key, '<space>', ' ', 'g')
        let new_dict[new_key] = a:key_dict[key]
    endfor
    return new_dict
endfunction

function! s:listen_commands(self, ...) dict
    redraw!
    let l:keys_dict = self.LoadIndex(self)
    let l:keys_dict = s:key_converter_for_input(l:keys_dict)
    let l:inputted_st = ""
    let l:first = v:true
    while v:true
        let l:c = ""
        if l:first && a:0 == 1
            let l:c = a:1
            let l:first = v:false
        elseif getchar(1)
            let l:c = getchar()
        else
            continue
        endif
        if l:c == 13
            " when <cr> plessed evaluate input immediately.
            let l:matched = deepcopy(filter(l:keys_dict, {key, _ -> l:inputted_st ==# key}))
        else
            let l:inputted_st = l:inputted_st . nr2char(l:c)
            let l:matched = deepcopy(filter(l:keys_dict, {key, _ -> s:incremental_search(l:inputted_st, key)}))
        endif
        call nvim_buf_set_lines(s:buf, 0, -1, v:true, s:formatter(l:matched, strchars(l:inputted_st), self.column_size))

        let buf_row = nvim_buf_line_count(s:buf)
        let row_offset = &cmdheight + (&laststatus > 0 ? 1 : 0)
        let k = {'height': buf_row, 'row': &lines-buf_row-row_offset-1, 'width': &columns-self.window.config.col}
        call self.window.update(self.window, k)

        call s:hyper_wich_syntax()

        redraw!

        if len(l:matched) == 1
            return l:matched
        endif
        if len(l:matched) == 0
            return l:matched
        endif
    endwhile
endfunction

function! s:On_Matched() dict
endfunction

function! s:After_Quit(self) dict
endfunction

function! s:Load_Index(self) dict
    return {}
endfunction

function! s:Event() dict
endfunction

function! s:key_selecter(self, ...) dict
    if a:0 == 1
        let l:matched = self.Listen(self, a:1)
    else
        let l:matched = self.Listen(self)
    endif
    if len(l:matched) == 1
        execute "quit"
        call self.OnMatched(keys(l:matched)[0])
        call self.AfterQuit(self)
    else
        echom "matched nothing"
        execute "quit"
        call self.AfterQuit(self)
    endif
endfunction

function! s:Witch(self, ...) dict
    let self.home_buf = luaeval("vim.api.nvim_win_get_buf(0)")

    let self.filetype=&filetype

    let s:buf = nvim_create_buf(v:false, v:true)

    let l:keys_dict = self.LoadIndex(self)
    let l:keys_dict = s:key_converter_for_input(l:keys_dict)

    if self.column_size < 55
        let self.column_size = &columns
    else
        let self.window.config.col = &columns - self.column_size
    endif
    call nvim_buf_set_lines(s:buf, 0,-1, v:true, s:formatter(l:keys_dict, 0, self.column_size))

    let buf_row = nvim_buf_line_count(s:buf)
    let row_offset = &cmdheight + (&laststatus > 0 ? 1 : 0)

    let k = {'height': buf_row, 'row': &lines-buf_row-row_offset-1, 'width': &columns-self.window.config.col}
    call self.window.start(self.window, k)
    setlocal filetype=evil_witch
    setlocal foldmethod=syntax

    call s:hyper_wich_syntax()

    nnoremap <silent> <buffer>
        \ <plug>(session-close)
        \ :<c-u>call s:escape()<cr>
    nmap <buffer> <silent> <esc> <plug>(session-close)


    if a:0 == 1
        if a:1 == "SPC"
            call self.CMDSelecter(self, char2nr(" "))
        else
            call self.CMDSelecter(self, char2nr(a:1))
        endif
    else
        call self.CMDSelecter(self)
    endif
endfunction

function! s:hyperwitch_new(...) dict
    let instance = deepcopy(self)
    let instance.win_config = {}
    let instance.window = instance.super().new()
    let instance.column_size = 0
    let instance.Listen = function('s:listen_commands')
    let instance.OnMatched = function("s:On_Matched")
    let instance.AfterQuit = function("s:After_Quit")
    let instance.LoadIndex = function("s:Load_Index")
    let instance.Event = function("s:Event")
    let instance.CMDSelecter = function("s:key_selecter")
    let instance.Witch = function("s:Witch")
    return instance
endfunction

let HyperWitch = Window.override("HyperWitch", function("s:hyperwitch_new"))
let hyperwitch = HyperWitch.new()
" }}}

" ---------------------------------------------------------
" HWich-Evil
" ---------------------------------------------------------
" {{{
" lua << EOF
" require("key_register")
" EOF

function! s:evil_On_Matched(key) dict
    let l:command = "normal a" . a:key
    try
        execute l:command
    catch /error!/
        echom "err occured"
    endtry
endfunction

function! s:evil_After_Quit(self) dict
    startinsert
endfunction

function! s:evil_Load_Index(self) dict
    return luaeval('_G.__kaza.k.i')
endfunction

function! s:evil_Event() dict
    command! KeyWindow :call evilwitch.Witch(evilwitch)
    "nnoremap <silent> <space>wevil :KeyWindow<CR>
    " inoremap <silent>   <esc>:KeyWindow<cr>
endfunction

let EvilWitch = #{
    \ __name: 'EvilWitch',
    \ OnMatched: function("s:evil_On_Matched"),
    \ AfterQuit: function("s:evil_After_Quit"),
    \ LoadIndex: function("s:evil_Load_Index"),
    \ Event: function("s:evil_Event")
    \ }

let evilwitch = hyperwitch.extend(EvilWitch)
call evilwitch.Event()
" }}}

" ---------------------------------------------------------
" HWich-Register
" ---------------------------------------------------------
" {{{
function! s:reg_On_Matched(key) dict
    let l:command = 'normal "' . a:key . 'p'
    try
        execute l:command
    catch /error!/
        echom "err occured"
    endtry
endfunction

function! s:reg_After_Quit(self) dict
    " startinsert!
endfunction

function! s:reg_Load_Index(self) dict
     let regs=split('abcdefghijklmnopqrstuvwxyz0123456789/-"', '\zs')
     let l:reg_index = {}
     for reg_key in regs
         let l:tmp_string = getreg(reg_key)
         let l:tmp_string = substitute(l:tmp_string, '[[:cntrl:]]', '', 'g')  " remove control character
         let l:tmp_string = substitute(l:tmp_string, '[^\d0-\d177]', '', 'g') " Japanese to alphabet
         if len(l:tmp_string) > 0
            let l:reg_index[reg_key] = l:tmp_string
         endif
     endfor
    return l:reg_index
endfunction
function! s:reg_Event() dict
    command! REGWITCH :call regwitch.Witch(regwitch)
    "nnoremap <silent> <space>wreg :REGWITCH<CR>
endfunction

let RegWitch = {
    \ '__name':'RegWitch',
    \ 'OnMatched': function("s:reg_On_Matched"),
    \ 'AfterQuit': function("s:reg_After_Quit"),
    \ 'LoadIndex': function("s:reg_Load_Index"),
    \ 'Event': function("s:reg_Event")}

if exists("regwitch")|unlet regwitch|endif
let regwitch = hyperwitch.extend(RegWitch)
call regwitch.Event()
" }}}

" ---------------------------------------------------------
" HWich-Tex
" ---------------------------------------------------------
" {{{
function! s:hwichtex_On_Matched(key) dict
    let l:command = 'normal! a\' . a:key
    try
        execute l:command
        execute 'normal w'
    catch /error!/
        echom "err occured"
    endtry
endfunction

function! s:hwichtex_After_Quit(self) dict
    startinsert!
endfunction

function! s:hwichtex_Load_Index(self) dict
    let tex_index = {
        \ "mathbb{R}":     "ℝ",
        \ "mathbb{z}":     "ℤ",
        \ "mathbb{n}":     "ℕ",
        \ "subset":        "⊂",
        \ "subseteq":      "⊆",
        \ "supset":        "⊃",
        \ "in":            "∈",
        \ "cap":           "∩",
        \ "cup":           "∪",
        \ "mid":           "∣",
        \ "notin":         "∉",
        \ "eq":            "=",
        \ "neq":           "≠",
        \ "sim":           "∼",
        \ "simeq":         "≃",
        \ "approx":        "≈",
        \ "fallingdotseq": "≒",
        \ "risingdotseq":  "≓",
        \ "equiv":         "≡",
        \ "geq":           "≥",
        \ "geqq":          "≧",
        \ "leq":           "≤",
        \ "leqq":          "≦",
        \ "gg":            "≫",
        \ "ll":            "≪",
        \ "oplus":         "⊕",
        \ "cdot":          "⋅",
        \ "bot":           "⊥",
        \ "sum":           "∑",
        \ "prod":          "∏",
        \ "int":           "∫",
        \ "infty":         "∞",
        \ "forall":        "∀",
        \ "exists":        "∃",
        \ "leftarrow":     "←",
        \ "rightarrow":    "→",
        \ "Leftarrow":     "⇐",
        \ "Rightarrow":    "⇒",
        \ "Leftrightarrow":"⇔",
        \ "theta":         "θ",
        \ "phi":           "ϕ",
        \ "psi":           "ψ",
        \ "Omega":         "Ω",
        \ "partial":       "∂",
        \ "xi":            "ξ",
        \ "delta":         "δ",
        \ "gamma":         "γ",
        \ "Gamma":         "Γ",
        \ "kappa":         "κ",
        \ "bullet":        "∙",
        \ "circ":          "∘",
        \ "quad":          "1 space",
        \ "qquad":         "2 space",
        \ "mathbf":        "vector",
        \ "mathbb":        "set",
        \ "bm":            "itaric bold (for lattice 'L')",
        \ "mathcal":       "cursive (calligraphy font",
        \ "textit":        "itaric",
        \ "textgt":        "gosick",
        \ "KwRet":         "Return (algorithm2e)",
        \ "tcp*[h]{ ${1:comment} }\;": "コメント(algorithm2e)",
        \ }
    " return map(tex_index, {-> substitute(v:key, '[^\d0-\d177]', '', 'g') })
    return tex_index
endfunction
function! s:hwichtex_Event() dict
    nnoremap <silent> <Plug>(hwich-tex) :<c-u>call hwichtex.Witch(hwichtex)<cr>
    " nmap <space>wtex <Plug>(hwich-tex)
endfunction

let Hwichtex = {
    \ '__name':'Hwichtex',
    \ 'OnMatched': function("s:hwichtex_On_Matched"),
    \ 'AfterQuit': function("s:hwichtex_After_Quit"),
    \ 'LoadIndex': function("s:hwichtex_Load_Index"),
    \ 'Event': function("s:hwichtex_Event")}

if exists("hwichtex")|unlet hwichtex|endif
let hwichtex = hyperwitch.extend(Hwichtex)
call hwichtex.Event()
" }}}

" ---------------------------------------------------------
" HWich-UltiSnips
" ---------------------------------------------------------
" {{{

" INFO
" search with file type -> filetype.snippet
" directory: g:UltiSnipsSnippetsDir like `~/.config/nvim/UltiSnips`
let s:ultisnips_index = {}

function! s:ultisnips_On_Matched(key) dict
    let command = "normal a" . a:key . "\<tab>"
    try
        " execute l:command
        execute command
    catch /error!/
        echom "err occured"
    endtry
endfunction

function! s:ultisnips_After_Quit(self) dict
    let self.column_size = 55
endfunction

" helper function
function! s:_parser(path)
    if !filereadable(a:path)
        echom 'file: ' . a:path . ' not exists'
        return {}
    endif
    let lines = readfile(a:path)
    let ret = {}
    for line in lines
        let table = split(line)
        if len(table) >= 3
            if table[0] ==# 'snippet'
                let ret[table[1]] = table[2]
            endif
        endif
    endfor
    return ret
endfunction

" (s:add_spaces(a:matched[l:k], 45)  , 0, 45)
function! s:gen_view(index)
    let index_view = {}
    for k in keys(a:index)
        let index_view[k] = '[' . k . '] ' . a:index[k]
    endfor
    return index_view
endfunction

function! s:ultisnips_Load_Index(self) dict
    if !exists("g:UltiSnipsSnippetDirectories")
        echom 'ultisnips not loaded on vim'
        return {}
    endif

    let path = '~/.config/nvim/' . g:UltiSnipsSnippetDirectories[0] . '/' . self.filetype . '.snippets'
    let new_index = s:_parser(expand(path))
    let ultisnips_index = new_index

    let index_view = {}
    for k in keys(new_index)
        let index_view[k] = '[' . k . '] ' . new_index[k]
    endfor


    return index_view
endfunction

function! s:ultisnips_Event() dict
    nnoremap <silent> <plug>(hwich-ultisnips) :<c-u>call ultisnips_wich.Witch(ultisnips_wich)<cr>
    " nmap <silent> <space>wult <plug>(hwich-ultisnips)
endfunction

let UltiSnipsWich = {
            \ '__name': 'UltiSnipsWich',
            \ 'column_size': 55,
            \ 'OnMatched': function("s:ultisnips_On_Matched"),
            \ 'AfterQuit': function("s:ultisnips_After_Quit"),
            \ 'LoadIndex': function("s:ultisnips_Load_Index"),
            \ 'Event': function("s:ultisnips_Event")
            \ }

let ultisnips_wich = hyperwitch.extend(UltiSnipsWich)
call ultisnips_wich.Event()
" }}}

" ---------------------------------------------------------
" HWich-Normal
" ---------------------------------------------------------
" {{{
function! s:get_raw_map_info(key) abort
  return split(execute('map '.a:key), "\n")
endfunction

function! s:normal_On_Matched(key) dict
    " let key_t = substitute(a:key, ' ', '\<space>', 'g')
    let key_t = substitute(a:key, '<tab>', nr2char(9), 'g')
    try
        " execute l:command
        call feedkeys(key_t)
    catch /error!/
        echom "err occured"
    endtry
endfunction

function! s:normal_After_Quit(self) dict
endfunction

function! s:normal_load_g_index()
   let keymap = luaeval('vim.api.nvim_get_keymap("n")')
   let ret = {}
   for key in keymap
       let desc = ''
       if has_key(key, 'desc')
           let desc = key['desc']
        else
            let desc = key['rhs']
       endif

       if key['lhs'] !~ "^<Plug>.*" && desc != "" && key['lhs'] !~ "^<C-.*"
           let ret[key['lhs']] = substitute(key['lhs'], ' ', g:hwhich_char_space, 'g') . ' ' . desc
       endif
   endfor
   return ret
endfunction

function! s:normal_load_b_index(parent)
   let cmd = 'vim.api.nvim_buf_get_keymap(' . a:parent.home_buf . ', "n")'
   let keymap = luaeval(cmd)
   let ret = {}
   for key in keymap
       let desc = '[buf] '
       if has_key(key, 'desc')
           let desc = desc . key['desc']
        else
            let desc = desc . key['rhs']
       endif
       if key['lhs'] !~ "^<Plug>.*" && desc != "" && key['lhs'] !~ "^<C-.*"
           let ret[key['lhs']] = key['lhs'] . ' ' . desc
       endif
   endfor
   return ret
endfunction

function! s:normal_Load_Index(self) dict
   let g = s:normal_load_g_index()
   let b = s:normal_load_b_index(self)
   call extend(g, b)
   return g
endfunction

function! s:normal_Event() dict
    nnoremap <silent>
        \ <plug>(hwhich-normal)
        \ :<c-u>call normalwitch.Witch(normalwitch)<cr>
    " nmap <silent> <space>wnor <plug>(hwhich-normal)
    command! -nargs=? NormalWitch call normalwitch.Witch(normalwitch, <f-args>)
endfunction

let NormalWitch = {
    \ '__name': 'NormalWitch',
     \ 'OnMatched': function("s:normal_On_Matched"),
     \ 'AfterQuit': function("s:normal_After_Quit"),
     \ 'LoadIndex': function("s:normal_Load_Index"),
     \ 'Event': function("s:normal_Event")
     \ }

let normalwitch = hyperwitch.extend(NormalWitch)
call normalwitch.Event()
" }}}

" ---------------------------------------------------------
" HWich-bookmark
" ---------------------------------------------------------
" {{{
let s:bookmark = {
            \ "home":     "~/.config/nvim",
            \ "fnl":      "~/.config/nvim/fnl",
            \ "kaza":     "~/.config/nvim/fnl/kaza",
            \ "core":     "~/.config/nvim/fnl/core",
            \ "plug":     "~/.config/nvim/plugin",
            \ "vim":      "~/.config/nvim/vim",
            \ "macros":   "~/.config/nvim/lua/macros",
            \ "packer":   "~/.config/nvim/fnl/core/pack/plugs.fnl",
            \ "snip":     "~/.config/nvim/UltiSnips",
            \ "which":    "~/.config/nvim/plugin/hyper_which.vim",
            \ "dotfile":  "~/dotfiles",
            \ "memo":     "~/tech-memo",
            \ "lua": "~/.cache/nvim/hotpot/Users/cassin/.config/nvim/fnl",
            \ "org": "~/Library/Mobile Documents/iCloud~com~appsonthemove~beorg/Documents/org/"
            \ }

" function! s:bookmark_On_Matched(key) dict
"     let command = "e " . s:bookmark[a:key]
"     try
"         " execute l:command
"         execute command
"     catch /error!/
"         echom "err occured"
"     endtry
" endfunction

function! s:bookmark_On_Matched(key) dict
    let path = s:bookmark[a:key]
    if isdirectory(expand(path))
        echom "is directory"
        let command = "CtrlP " . path
    else
        let command = "vi " . path
    endif
    try
        execute command
    catch /error!/
        echom "err occured"
    endtry
endfunction

function! s:bookmark_After_Quit(self) dict
    "let self.column_size = 55
endfunction

function! s:max_length(index)
    let length = 0
    for k in keys(a:index)
        if length < len(k)
            let length = len(k)
        endif
    endfor
    return length
endfunction

function! s:bookmark_Load_Index(self) dict
    let bookmark_view = {}
    let max_key_length = s:max_length(s:bookmark)
    for k in keys(s:bookmark)
        let bookmark_view[k] = strpart(s:add_spaces('[' . k . ']',max_key_length+3),0,max_key_length+3) . s:bookmark[k]
    endfor
    return bookmark_view
endfunction
" (s:add_spaces(a:matched[l:k], 45)  , 0, 45)

function! s:bookmark_Event() dict
    nnoremap <silent> <plug>(hwhich-bookmark) :<c-u>call bookmark_wich.Witch(bookmark_wich)<cr>
    " nmap <silent> <space>wbook <plug>(hwhich-bookmark)
endfunction

let BookmarkWich = {
            \ '__name': 'BookmarkWich',
            \ 'column_size': 55,
            \ 'OnMatched': function("s:bookmark_On_Matched"),
            \ 'AfterQuit': function("s:bookmark_After_Quit"),
            \ 'LoadIndex': function("s:bookmark_Load_Index"),
            \ 'Event': function("s:bookmark_Event")
            \ }

let bookmark_wich = hyperwitch.extend(BookmarkWich)
call bookmark_wich.Event()
" }}}
