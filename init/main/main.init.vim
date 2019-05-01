scriptencoding utf-8

set fenc=utf-8
set nobackup
set noswapfile
set autoread
set tabstop=2 shiftwidth=2 expandtab
set number
"set scrolloff=5
set scrolloff=10
filetype plugin indent on

"set laststatus=2

"tex ギリシャ文字可視化無効
let g:tex_conceal = ''

" 英語と日本語のスペルチェック z= で修正候補
set spell
set spelllang=en,cjk

hi clear SpellBad
""hi SpellBad cterm=underline
hi clear SpellCap
""hi SpellCap cterm=underline,bold


" remove trailing whitespace
" autocmd BufWritePre * :%s/\s\+$//ge
