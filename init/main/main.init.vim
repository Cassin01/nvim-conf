scriptencoding utf-8

set fenc=utf-8
set nobackup
set noswapfile
set autoread
set tabstop=2 shiftwidth=4 expandtab
set number
set scrolloff=10
filetype plugin indent on

"set laststatus=2

"tex ギリシャ文字可視化無効
let g:tex_conceal = ''

" 英語と日本語のスペルチェック z= で修正候補
set spell
set spelllang=en,cjk

hi clear SpellBad
""hi clear SpellCap

" remove trailing whitespace
" autocmd BufWritePre * :%s/\s\+$//ge

au BufNewFile start.rs 0r $HOME/.config/nvim/template/main.rs
au BufNewFile start.go 0r $HOME/.config/nvim/template/main.go

let g:python2_host_prog = '/usr/local/bin/python'
let g:python3_host_prog = '/usr/local/bin/python3'
