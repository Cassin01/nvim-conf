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

    " Haskell {{{
        au ColorScheme * hi Haskell01 ctermfg=179  " 黄色
        au ColorScheme * hi Haskell02 ctermfg=45   " 水色
        au ColorScheme * hi Haskell03 ctermfg=255  " 白
        au ColorScheme * hi Haskell04 ctermfg=240  " 灰色
    " }}}

    " Prefix for color scheme {{{
        " Color scheme extension  " molokai {{{
            function! s:molokai()
                if g:colors_name == "molokai"
                    " コメントアウト
                    hi Comment ctermfg=244 cterm=italic

                    " blacket
                    hi MatchParen cterm=bold ctermfg=214 ctermbg=black

                    " Check spells
                    "hi SpellBad ctermfg=none ctermbg=none cterm=underline

                    " Conceal {{{
                        " Note:
                        " vim2hsというHaskell用
                        " のプラグインにてlambda式(\)がλに変換されるがこのとき見にくいので
                    hi clear Conceal
                    hi Conceal ctermbg=1 ctermbg=darkblue
                    " }}}
                endif
            endfunction
        " }}}

        " Color scheme extension  " one dark {{{
            function! s:onedark()
                if g:colors_name == "onedark"
                    hi Normal       ctermbg=none

                    " 行番号
                    hi LineNr       ctermbg=none ctermfg=240 cterm=italic

                    " アクティブなステータスライン
                    hi StatusLine   ctermbg=none

                     " 非アクティブなステータスライン
                    hi StatusLineNC ctermbg=none

                    " コメントアウト
                    hi Comment      ctermfg=243 cterm=italic

                    hi Statement    ctermfg=45

                    " 追加行
                    hi DiffAdd      ctermbg=24

                    hi Identifier   ctermfg=45 "cterm=bold
                endif
            endfunction
        " }}}

        " Color scheme extension " night_owl {{{
            function! s:iceberg()
                if g:colors_name == "iceberg"
                    " bracket
                    hi MatchParen cterm=bold ctermfg=214 ctermbg=black
                endif
            endfunction
        " }}}

        " Color scheme extension " nord {{{
            function! s:nord()
                if g:colors_name == "nord"
                    " bracket
                    hi MatchParen cterm=bold ctermfg=214 ctermbg=black

                    " Check spells
                    hi SpellBad ctermfg=none ctermbg=none cterm=underline
                endif
            endfunction
        " }}}

        " Color scheme extension " purify {{{
            function! s:purify()
                if g:colors_name == "purify"
                    let g:airline_theme='purify'
                endif
            endfunction
        " }}}

        " Prefix for color schemes
        au ColorScheme * :call s:onedark()
        au ColorScheme * :call s:iceberg()
        au ColorScheme * :call s:nord()
        au ColorScheme * :call s:molokai()
        au ColorScheme * :call s:purify()
    " }}}
" }}}

" Set color scheme {{{
    set background=dark
    "colo Tomorrow                " 明るいところ、逆光で見やすい
    colo mrkn256                " 暗闇で見やすい

    "colo molokai
    "colo iceberg
    "colo nord
    "colo night-owl
    "colo onedark
    "colo Tomorrow-Night-Bright
    "colo gruvbox               " default
    "colo tomorrow
    "colo hybrid
" }}}

" 行末スペース、行末タブの表示 {{{
    " highlight TrailingSpaces ctermbg=red guibg=#FF0000
    " highlight TrailingSpaces ctermbg=blue guibg=#FF0000
    "46 (緑), 240 (灰色), 50 (水色)
    highlight TrailingSpaces ctermbg=50 ctermfg=50 cterm=bold
    highlight Tabs ctermbg=black guibg=8 " guibg=#000000
    au BufNewFile,BufRead * call matchadd('TrailingSpaces', ' \{-1,}$')
    au BufNewFile,BufRead * call matchadd('Tabs', '\t')
" }}}

" 全角スペースの表示 {{{
    highlight ZenkakuSpace cterm=underline ctermbg=BLUE
    au BufWinEnter * let w:m3 = matchadd("ZenkakuSpace", '　')
    au WinEnter    * let w:m3 = matchadd("ZenkakuSpace", '　')
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
" }}}
