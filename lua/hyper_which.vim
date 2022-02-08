" -----------------------------------------------------
" Object
" -----------------------------------------------------
" {{{
function! Class_Prototype() dict
    return self
endfunction

function! Class_Override(name, class_new) dict
    let class = copy(self)
    let class.__NAME = a:name
    let class.New = a:class_new
    let class.__SUPER = self
    return class
endfunction

function! Class_Extend(class) dict
    let class = copy(self)
    let class = extend(class, a:class)
    return class
endfunction

function! Class_New() dict
    let instance = copy(self)
    call remove(instance, "New")
    call remove(instance, "Override")
    let instance.__SUPER = self
    return instance
endfunction

function! Class_ToStrting() dict
    return self.__NAME
endfunction

let Object = {
    \ "__NAME": "Object",
    \ "Prototype": function("Class_Prototype"),
    \ "Override": function("Class_Override"),
    \ "Extend" : function("Class_Extend"),
    \ "__SUPER": {},
    \ "New": function("Class_New"),
    \ "ToString": function("Class_ToStrting")}

" TEST
" if exists("object")|unlet object|endif
" let object = Object.New()
" echo object.ToString()
" }}}

" ---------------------------------------------------------
" Hyper Witch
" ---------------------------------------------------------
" {{{
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
function! s:formatter(matched, inputed_length)
    let l:formatted_lines = []
    for l:k in sort(keys(a:matched))
        call add(l:formatted_lines, '      ' . strcharpart(l:k, a:inputed_length, a:inputed_length+1) . ' → ' .  strpart(s:add_spaces(a:matched[l:k], 45)  , 0, 45) )
    endfor

    " 列の数
    let s:split_num = &columns / 50

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
" }}}

" ---------------------------------------------------------
" Hyper Witch methods
" ---------------------------------------------------------
"  {{{
function! s:listen_commands(self) dict
    redraw!
    setlocal filetype=evil_witch
    " let l:keys_dict = luaeval('keys:get_i()') " MARK: 継承
    let l:keys_dict = self.LoadIndex()
    let l:inputted_st = ""
    while v:true
        let l:c = ""
        if getchar(1)
            let l:c = getchar()
        else
            continue
        endif
        let l:inputted_st = l:inputted_st . nr2char(l:c)
        echom nr2char(l:c)
        echom l:keys_dict
        let l:matched = copy(filter(l:keys_dict, {key, _ -> s:incremental_search(l:inputted_st, key)}))
        echom l:keys_dict

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

function! s:On_Matched() dict
endfunction

function! s:After_Quit() dict
endfunction

function! s:Load_Index() dict
    return {}
endfunction

function! s:Event() dict
endfunction

function! s:key_selecter(self) dict
    let l:matched = self.Listen(self)
    if len(l:matched) == 1
        execute "quit"
        call self.OnMatched(keys(l:matched)[0])
        call self.AfterQuit()
    else
        echom "matched nothing"
        execute "quit"
        call self.AfterQuit()
    endif
endfunction

function! s:Witch(self) dict
    let s:buf = nvim_create_buf(v:false, v:true)

    let l:keys_dict = self.LoadIndex() " MARK: 継承
    call nvim_buf_set_lines(s:buf, 0, 0, v:true, s:formatter(l:keys_dict, 0))

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

    " command! WichESC call s:escape()
    " nnoremap <buffer> <silent> <esc> :WichESC<CR>

    nnoremap <silent> <buffer>
        \ <plug>(session-close)
        \ :<c-u>call s:escape()<cr>
    nmap <buffer> <silent> <esc> <plug>(session-close)


    call self.CMDSelecter(self)
endfunction

function! HyperWitch_New(...) dict
    let instance = copy(self)
    let instance.Listen = function('s:listen_commands')
    let instance.OnMatched = function("s:On_Matched")
    let instance.AfterQuit = function("s:After_Quit")
    let instance.LoadIndex = function("s:Load_Index")
    let instance.Event = function("s:Event")
    let instance.CMDSelecter = function("s:key_selecter")
    let instance.Witch = function("s:Witch")
    return instance
endfunction

let HyperWitch = Object.Override("HyperWitch", function("HyperWitch_New"))
let hyperwitch = HyperWitch.New()
" }}}

" ---------------------------------------------------------
" HWich-EvilWitch
" ---------------------------------------------------------
" {{{
lua << EOF
require("key_register")
EOF

function! s:evil_On_Matched(key) dict
    let l:command = "normal a" . a:key
    try
        execute l:command
    catch /error!/
        echom "err occured"
    endtry
endfunction

function! s:evil_After_Quit() dict
    startinsert
endfunction

function! s:evil_Load_Index() dict
    return luaeval('keys:get_i()')
endfunction

function! s:evil_Event() dict
    command! KeyWindow :call evilwitch.Witch(evilwitch)
    nnoremap <silent> ,evil :KeyWindow<CR>
    inoremap <silent>   <esc>:KeyWindow<cr>
endfunction

let EvilWitch = {
    \ '__NAME': 'EvilWitch',
     \ 'OnMatched': function("s:evil_On_Matched"),
     \ 'AfterQuit': function("s:evil_After_Quit"),
     \ 'LoadIndex': function("s:evil_Load_Index"),
     \ 'Event': function("s:evil_Event")
     \ }

let evilwitch = hyperwitch.Extend(EvilWitch)
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

function! s:reg_After_Quit() dict
    " startinsert!
endfunction

function! s:reg_Load_Index() dict
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
    nnoremap <silent> ,reg :REGWITCH<CR>
endfunction

let RegWitch = {
    \ '__NAME':'RegWitch',
    \ 'OnMatched': function("s:reg_On_Matched"),
    \ 'AfterQuit': function("s:reg_After_Quit"),
    \ 'LoadIndex': function("s:reg_Load_Index"),
    \ 'Event': function("s:reg_Event")}

if exists("regwitch")|unlet regwitch|endif
let regwitch = hyperwitch.Extend(RegWitch)
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

function! s:hwichtex_After_Quit() dict
    startinsert!
endfunction

function! s:hwichtex_Load_Index() dict
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
        \ "quad": "1文字分のスペース",
        \ "qquad": "2文字分のスペース",
        \ "mathbf": "太字(ベクトル等)",
        \ "mathbb": "黒板太字(集合)",
        \ "bm": "斜体太字(格子Lに使う)",
        \ "mathcal": "筆記体",
        \ "textit": "イタリック",
        \ "textgt": "ゴシック",
        \ "KwRet": "Return (algorithm2e)",
        \ "tcp*[h]{ ${1:comment} }\;": "コメント(algorithm2e)",
        \ }
    " return map(tex_index, {-> substitute(v:key, '[^\d0-\d177]', '', 'g') })
    return tex_index
endfunction
function! s:hwichtex_Event() dict
    nnoremap <silent> <Plug>(hwich-tex) :<c-u>call hwichtex.Witch(hwichtex)<cr>
    nmap ,tex <Plug>(hwich-tex)
endfunction

let Hwichtex = {
    \ '__NAME':'Hwichtex',
    \ 'OnMatched': function("s:hwichtex_On_Matched"),
    \ 'AfterQuit': function("s:hwichtex_After_Quit"),
    \ 'LoadIndex': function("s:hwichtex_Load_Index"),
    \ 'Event': function("s:hwichtex_Event")}

if exists("hwichtex")|unlet hwichtex|endif
let hwichtex = hyperwitch.Extend(Hwichtex)
call hwichtex.Event()
" }}}

" -----------------------------------------------------
" HWich-UltiSnips
" -----------------------------------------------------

" -----------------------------------------------------
" HWich-Normal
" -----------------------------------------------------
" {{{
" WARN: NOT WORKING YET
function! s:normal_On_Matched(key) dict
    let l:command = "normal " . a:key
    try
        execute l:command
    catch /error!/
        echom "err occured"
    endtry
endfunction

function! s:normal_After_Quit() dict
endfunction

function! s:normal_Load_Index() dict
    return luaeval('keys:get_n()')
endfunction

function! s:normal_Event() dict
    nnoremap <silent> <buffer>
        \ <plug>(hwhich-normal)
        \ :<c-u>call normalwitch.Witch(normalwitch)<cr>
    nmap <silent> ,nor <plug>(hwhich-normal)
endfunction

let NormalWitch = {
    \ '__NAME': 'NormalWitch',
     \ 'OnMatched': function("s:normal_On_Matched"),
     \ 'AfterQuit': function("s:normal_After_Quit"),
     \ 'LoadIndex': function("s:normal_Load_Index"),
     \ 'Event': function("s:normal_Event")
     \ }

let normalwitch = hyperwitch.Extend(NormalWitch)
call normalwitch.Event()
" }}}
