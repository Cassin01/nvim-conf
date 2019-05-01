scriptencoding utf-8


syntax on

" 179 : 黄色
" 51  : 水色 (少し明るい)
" 45  : 水色
" 6   : 水色 (少し暗い)
" 24  : 水色 (より暗い)
" 255 : 白色
" 240 : 灰色




" color scheme 拡張 " one dark
au ColorScheme * hi Normal       ctermbg=none
au ColorScheme * hi LineNr       ctermbg=none ctermfg=240 cterm=italic " 行番号
au ColorScheme * hi StatusLine   ctermbg=none " アクティブなステータスライン
au ColorScheme * hi StatusLineNC ctermbg=none " 非アクティブなステータスライン
au ColorScheme * hi Comment      ctermfg=243 cterm=italic " コメントアウト
au ColorScheme * hi Statement    ctermfg=45
au ColorScheme * hi DiffAdd      ctermbg=24  " 追加行
au ColorScheme * hi Identifier   ctermfg=45 "cterm=bold

au ColorScheme * hi Haskell01 ctermfg=179 " 黄色
au ColorScheme * hi Haskell02 ctermfg=45  " 水色
au ColorScheme * hi Haskell03 ctermfg=255 " 白

" スペルチェック
au Colorscheme * hi SpellBad ctermfg=46 cterm=none
" キャメルケースチェック
au ColorScheme * hi SpellCap ctermfg=46 cterm=bold



set background=light
colo onedark
"colo tomorrow
"colo hybrid


augroup filetypedetect
  au BufRead,BufNewFile *.hs :call ColHaskell()
augroup END


" Haskell 用のシンタックスハイライト
function! ColHaskell()
  au BufWinEnter * let w:m3 = matchadd("Haskell02", '(')
  au WinEnter    * let w:m3 = matchadd("Haskell02", '(')
  au BufWinEnter * let w:m3 = matchadd("Haskell02", ')')
  au WinEnter    * let w:m3 = matchadd("Haskell02", ')')
  au BufWinEnter * let w:m3 = matchadd("Haskell02", '$')
  au WinEnter    * let w:m3 = matchadd("Haskell02", '$')
endfunction


" 行末スペース、行末タブの表示
" highlight TrailingSpaces ctermbg=red guibg=#FF0000
" highlight TrailingSpaces ctermbg=blue guibg=#FF0000
highlight TrailingSpaces ctermbg=50 " or 46 (緑) or 240 (灰色)
highlight Tabs ctermbg=black guibg=8 " guibg=#000000
au BufNewFile,BufRead * call matchadd('TrailingSpaces', ' \{-1,}$')
au BufNewFile,BufRead * call matchadd('Tabs', '\t')

" 全角スペースの表示
highlight ZenkakuSpace cterm=underline ctermbg=BLUE
au BufWinEnter * let w:m3 = matchadd("ZenkakuSpace", '　')
au WinEnter    * let w:m3 = matchadd("ZenkakuSpace", '　')
