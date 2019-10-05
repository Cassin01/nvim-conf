scriptencoding utf-8

" Initialization {{{
    set fenc=utf-8
    set nobackup
    set noswapfile
    set autoread
    set tabstop=2 shiftwidth=4 expandtab
    set number
    set scrolloff=10
    filetype plugin indent on

    nnoremap [m] <Nop>
    nmap     m [m]
" }}}

" Visualize {{{
    set list
    set listchars=tab:»-,trail:†,eol:↲

    " 英語と日本語のスペルチェック z= で修正候補
    set spell
    set spelllang=en,cjk

    hi clear SpellBad
    " hi clear SpellCap

    "検索で大文字小文字を区別しない
    set ignorecase
" }}}

" Pythons path {{{
    let g:python2_host_prog = '/usr/local/bin/python'
    let g:python3_host_prog = '/usr/local/bin/python3'
" }}}

" Don't use Now but ... {{{
    " remove trailing whitespace
    " autocmd BufWritePre * :%s/\s\+$//ge
" }}}
