scriptencoding utf-8

" Initialization {{{
    set fenc=utf-8
    set nobackup
    set noswapfile
    set autoread
    set tabstop=4 shiftwidth=4 expandtab
    set number
    set scrolloff=10
    filetype plugin indent on

    " 行
    set cursorline

    " 列
    "set cursorcolumn

    " mouse
    set mouse=a

    " veonimの文字化け防止
    lang en_US.UTF-8

    " vimでファイルを開いたとき最後にカーソルがあった場所に移動 {{{
    augroup vimrcEx
        au BufRead * if line("'\"") > 0 && line("'\"") <= line("$") |
                    \ exe "normal g`\"" | endif
    augroup END
    " }}}

    " True colors {{{
    set termguicolors
    " $TERMがxterm以外のときは以下を設定する必要がある。
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum" " 文字色
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum" " 背景色
    " }}}

    " Default color scheme {{{
    let g:my_color = 'purify'

    "colo industry
    "colo Tomorrow              " 明るいところ、逆光で見やすい
    "colo goodwolf              " 明るいところでmardown見やすい
    "colo mrkn256               " 暗闇で見やすい
    "colo molokai
    "colo iceberg
    "colo nord
    "colo night-owl
    "colo onedark
    "colo Tomorrow-Night-Bright
    "colo gruvbox               " default
    "colo tomorrow
    "colo hybrid
    "colo torte                 " defaultっぽいくらいところで見やすい
    " }}}
" }}}

" Visualize {{{
    " 不可視文字 {{{
        set list
        "set listchars=tab:»-,trail:_,eol:↲
        set listchars=tab:»-,trail:□
    " }}}

    " 英語と日本語のスペルチェック z= で修正候補 {{{
        set spell
        set spelllang=en,cjk
        hi clear SpellBad
    " }}}

    "検索で大文字小文字を区別しない
    set ignorecase
" }}}

