scriptencoding utf-8

syntax on

" color definition {{{
    " NOTE: color {{{
        " 179 : 黄色
        " 51  : 水色 (少し明るい)
        " 45  : 水色
        " 6   : 水色 (少し暗い)
        " 24  : 水色 (より暗い)
        " 255 : 白色
        " 240 : 灰色
        " 111 : 薄青 (暗)
        " 214 : オレンジ (暗)
    " }}}

    " Check {{{
        " スペルチェック
        au Colorscheme * hi SpellBad ctermfg=none ctermbg=none cterm=underline
    " }}}

    " Tab, Space, etc...{{{
        " NOTE:
        "   * NonText
        "     * eol, extends, precedes
        "   * SpecialKey
        "     * nbsp, tab, trail
        au Colorscheme * hi NonText    ctermbg=None ctermfg=13
        au Colorscheme * hi SpecialKey ctermbg=None ctermfg=13 cterm=italic
    " }}}

    " Visual mode {{{
        au Colorscheme * hi Visual cterm=reverse
    " }}}

    " mark {{{
        au ColorScheme * hi InterestingWord1 ctermfg=0 ctermbg=47  " みどり
        au ColorScheme * hi InterestingWord2 ctermfg=0 ctermbg=45  " 水色
        au ColorScheme * hi InterestingWord3 ctermfg=0 ctermbg=212 " ピンク
    " }}}

    " cursourline {{{
    "    au ColorScheme * hi CursorLine term=bold cterm=bold guibg=Grey40
    " }}}

    " Haskell {{{
        au ColorScheme * hi Haskell01 ctermfg=179  " 黄色
        au ColorScheme * hi Haskell02 ctermfg=45   " 水色
        au ColorScheme * hi Haskell03 ctermfg=255  " 白
        au ColorScheme * hi Haskell04 ctermfg=240  " 灰色
    " }}}

    " a note using floating window
    au ColorScheme * hi MMathGlossary ctermfg=255 ctermbg=0

    " Prefix for color scheme {{{
        " Color scheme extension  " molokai {{{
            function! s:molokai()
                " " コメントアウト
                " hi Comment ctermfg=244 cterm=italic

                " `(` と `)`
                hi Delimiter cterm=bold ctermfg=116

                " コメントアウト
                "hi Comment ctermfg=47 cterm=italic
                hi Comment ctermfg=179 cterm=italic

                " blacket
                hi MatchParen cterm=bold ctermfg=214 ctermbg=black

                " Check spells
                "hi SpellBad ctermfg=none ctermbg=none cterm=underline

                " Conceal {{{
                    " Note:
                    " vim2hsというHaskell用
                    " のプラグインにてlambda式(\)がλに変換されるがこのとき背景色と被り見にくいので
                    hi clear Conceal
                    hi Conceal ctermbg=1 ctermbg=darkblue
                " }}}
            endfunction
        " }}}

        " Color scheme extension  " one dark {{{
            function! s:onedark()
                hi Normal       ctermbg=none

                " 行番号
                hi LineNr       ctermbg=none ctermfg=240 cterm=italic

                " アクティブなステータスライン
                hi StatusLine   ctermbg=none

                " 非アクティブなステータスライン
                hi StatusLineNC ctermbg=none

                " コメントアウト
                "hi Comment      ctermfg=243 cterm=italic
                hi Comment ctermfg=179 cterm=italic

                hi Statement    ctermfg=45

                " 追加行
                hi DiffAdd      ctermbg=24

                hi Identifier   ctermfg=45 "cterm=bold
            endfunction
        " }}}

        " Color scheme extension " night_owl {{{
            function! s:iceberg()
                " bracket
                hi MatchParen cterm=bold ctermfg=214 ctermbg=black
            endfunction
        " }}}

        " Color scheme extension " nord {{{
            function! s:nord()
                " bracket
                hi MatchParen cterm=bold ctermfg=214 ctermbg=black

                " Check spells
                hi SpellBad ctermfg=none ctermbg=none cterm=underline
            endfunction
        " }}}

        " Color scheme extension " purify {{{
            function! s:purify()
                let g:airline_theme='purify'
                " hi CursorLine gui=none guibg=#181c27
                hi CursorLine gui=none guibg=#242a3b
            endfunction
        " }}}

        " Color scheme extension " wolf {{{
            function! s:wolf()
                " コメントアウト
                hi Comment ctermfg=179 cterm=italic
                hi Normal ctermbg=0
                hi Folded ctermfg=208
            endfunction
        " }}}

        " Color scheme extension " mrkn256 {{{
            function! s:mrkn256()
                " blacket
                hi MatchParen cterm=bold ctermfg=214 ctermbg=black

                hi Normal ctermbg=black

                hi CursorLine term=bold cterm=bold guibg=Grey40
            endfunction
        " }}}

        " Color scheme extension " default {{{
            function! s:default()
                " blacket
                hi MatchParen cterm=bold ctermfg=214 ctermbg=black
            endfunction
        " }}}

        " Prefix for color schemes
        au ColorScheme * :call s:set_each_color_settings()
        function! s:set_each_color_settings()
            if g:colors_name == "molokai"
                call s:molokai()
            elseif g:colors_name == "onedark"
                call s:onedark()
            elseif g:colors_name == "iceberg"
                call s:iceberg()
            elseif g:colors_name == "nord"
                call s:nord()
            elseif g:colors_name == "purify"
                call s:purify()
            elseif g:colors_name == "goodwolf"
                call s:wolf()
            elseif g:colors_name == "badwolf"
                call s:wolf()
            elseif g:colors_name == "mrkn256"
                call s:mrkn256()
            elseif g:colors_name == "default"
                call s:default()
            else
            endif
        endfunction
    " }}}
" }}}

":terminal color {{{
" reference:
"   Docs on setting terminal colors? #2897
"   https://github.com/neovim/neovim/issues/2897
let g:terminal_color_0  = '#2e3436'
let g:terminal_color_1  = '#cc0000'
let g:terminal_color_2  = '#4e9a06'
let g:terminal_color_3  = '#c4a000'
let g:terminal_color_4  = '#3465a4'
let g:terminal_color_5  = '#75507b'
let g:terminal_color_6  = '#0b939b'
let g:terminal_color_7  = '#d3d7cf'
let g:terminal_color_8  = '#555753'
let g:terminal_color_9  = '#ef2929'
let g:terminal_color_10 = '#8ae234'
let g:terminal_color_11 = '#fce94f'
let g:terminal_color_12 = '#729fcf'
let g:terminal_color_13 = '#ad7fa8'
let g:terminal_color_14 = '#00f5e9'
let g:terminal_color_15 = '#eeeeec'
" }}}

" Set color scheme {{{
    set background=dark
    if exists('g:my_color')
        exe("colo ". g:my_color)
    else
        echom 'Err: g:my_color is not exists. [at othermap.init.vim]'
    endif
" }}}

" 行末スペース、行末タブの表示 {{{
    " highlight TrailingSpaces ctermbg=red guibg=#FF0000
    " highlight TrailingSpaces ctermbg=blue guibg=#FF0000
    "46 (緑), 240 (灰色), 50 (水色)
    highlight TrailingSpaces ctermbg=50 ctermfg=50 guibg=#FF0000 cterm=bold
    highlight Tabs ctermbg=black guibg=#eeeeec guibg=#FF0000
    " au BufNewFile,BufRead * call matchadd('TrailingSpaces', ' \{-1,}$')
    " au BufNewFile,BufRead * call matchadd('Tabs', '\t')
    " syntax match TrailingSpaces ' \{-1,}$'
    syntax match Tabs '\t'
" }}}

" 全角スペースの表示 {{{
    highlight ZenkakuSpace cterm=underline ctermbg=BLUE guibg=#FF0000
    " au BufWinEnter * let w:m3 = matchadd("ZenkakuSpace", '　')
    " au WinEnter    * let w:m3 = matchadd("ZenkakuSpace", '　')
    " syntax match ZenkakuSpace '\<　\>'
" }}}

" Specific fords  {{{
    highlight TodoEX guifg=none guibg=#4e9a06
    highlight TodoEX2 guifg=none guibg=#c4a000
    " highlight default link Todo TodoEX
    " highlight default link Todo TodoEX2
     highlight! link Todo TodoEX
     highlight! link Todo TodoEX2
" }}}

" match:
" {{{
augroup call_match
    autocmd!
    autocmd ColorScheme * call s:add_todo()
    autocmd BufRead,BufNew * call s:add_todo()
augroup END


let s:todo_ignore_filetype = ['dashboard', 'help', 'nerdtree', 'telescopePrompt', '']

function! s:find(val)
    return len(filter(copy(s:todo_ignore_filetype), {index, val -> val ==? a:val})) > 0
endfunction

function! s:matched(key)
    for k in getmatches()
        if k['group'] == a:key
            return v:true
        endif
    endfor
    return v:false
endfunction

function! s:add_todo()
    if s:find(&filetype)
        call clearmatches()
        return
    endif
    if s:matched('TodoEX')
        return
    endif

    call matchadd('TrailingSpaces', ' \+$')
    call matchadd('Tabs', '\t')
    call matchadd('ZenkakuSpace', '　')
    call matchadd('TodoEX', '\<\(NOTE\|MARK\|OPTION\|CHANGED\|IDEA\|REVIEW\|NB\|QUESTION\|COMBAK\|TEMP\|DEBUG\|OPTIMIZE\|REVIEW\)')
    call matchadd('TodoEX2', '\<\(INFO\|REFACTOR\|DEPRECATED\|TASK\|UPDATE\|EXAMPLE\|ERROR\|WARN\|BROKEN\)')

" ## NOTE: TODO highlighting
" DEFAULT: TODO FIXME HACK XXX WARNING
" ### ref: https://qiita.com/taka-kawa/items/673716d77795c937d422
" - TODO: あとで追加、修正するべき機能がある。
" - FIXME: 既知の不具合があるコード。修正が必要。
" - HACK: あまりきれいじゃないコード。リファクタリングが必要。
" - XXX: 危険！動くけどなぜうごくかわからない。
" - REVIEW: 意図した通りに動くか、見直す必要がある。
" - OPTIMIZE: 無駄が多く、ボトルネックになっている。
" - CHANGED: コードをどのように変更したか。
" - NOTE: なぜ、こうなったという情報を残す。
" - WARNING: 注意が必要。
" ###  [atom language-todo](https://github.com/atom/language-todo)
" - IDEA
" - NB: 厄介なバグ `nasty bug` [1]
" - QUESTION: 疑問
" - COMBACK: "I have something more urgent to do, let's mark this place so that I can COMBAK to it later" [2]
" - TEMP: 一時的な
" - DEBUG: [3]
" - OPTIMIZE: やれたらやる
" [1](https://forums.codeguru.com/showthread.php?177925-what-NB-stands-for)
" [2](https://stackoverflow.com/questions/27411211/what-does-the-comment-combak-mean)
" [3](https://www.embeddedcomputing.com/technology/debug-and-test/probes-debuggers/comments-and-debug-code)
" ### [atom language-todo-extention](https://github.com/BenjaminHoegh/language-todo-extended)
" - INFO
" - REFACTOR
" - DEPRECATED
" - TASK
" - UPDATE
" - EXAMPLE
" - ERROR
" - WARN
" - BROKEN
endfunction
" }}}
" }}}

" ハイライトグループの確認 {{{
    " Note: :SyntaxInfo でカーソルの下にあるコードのハイライトグループがわかる
    function! s:get_syn_id(transparent)
      let synid = synID(line("."), col("."), 1)
      if a:transparent
        return synIDtrans(synid)
      else
        return synid
      endif
    endfunction
    function! s:get_syn_attr(synid)
      let name = synIDattr(a:synid, "name")
      let ctermfg = synIDattr(a:synid, "fg", "cterm")
      let ctermbg = synIDattr(a:synid, "bg", "cterm")
      let guifg = synIDattr(a:synid, "fg", "gui")
      let guibg = synIDattr(a:synid, "bg", "gui")
      return {
            \ "name": name,
            \ "ctermfg": ctermfg,
            \ "ctermbg": ctermbg,
            \ "guifg": guifg,
            \ "guibg": guibg}
    endfunction
    function! s:get_syn_info()
      let baseSyn = s:get_syn_attr(s:get_syn_id(0))
      echo "name: " . baseSyn.name .
            \ " ctermfg: " . baseSyn.ctermfg .
            \ " ctermbg: " . baseSyn.ctermbg .
            \ " guifg: " . baseSyn.guifg .
            \ " guibg: " . baseSyn.guibg
      let linkedSyn = s:get_syn_attr(s:get_syn_id(1))
      echo "link to"
      echo "name: " . linkedSyn.name .
            \ " ctermfg: " . linkedSyn.ctermfg .
            \ " ctermbg: " . linkedSyn.ctermbg .
            \ " guifg: " . linkedSyn.guifg .
            \ " guibg: " . linkedSyn.guibg
    endfunction
    command! SyntaxInfo call s:get_syn_info()
    " nnoremap <buffer> <silent> ,n :SyntaxInfo<CR>
    nnoremap <silent> ,n :SyntaxInfo<CR>
" }}}

" https://zenn.dev/kawarimidoll/articles/cf6caaa7602239
" {{{
command! -nargs=+ -complete=highlight MergeHighlight call s:MergeHighlight(<q-args>)
function! s:MergeHighlight(args) abort
  let l:args = split(a:args)
  if len(l:args) < 2
    echoerr '[MergeHighlight] At least 2 arguments are required.'
    echoerr 'New highlight name and source highlight names.'
    return
  endif

  " skip 'links' and 'cleared'
  execute 'highlight' l:args[0] l:args[1:]
      \ ->map({_, val -> substitute(execute('highlight ' . val),  '^\S\+\s\+xxx\s', '', '')})
      \ ->filter({_, val -> val !~? '^links to' && val !=? 'cleared'})
      \ ->join()
endfunction
" }}}
