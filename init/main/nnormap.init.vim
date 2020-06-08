scriptencoding utf-8

" Initialization {{{
    nnoremap [m] <Nop>
    nnoremap mm m
    nmap m [m]

    nnoremap [,] <Nop>
    nnoremap ,, ,
    nmap , [,]

    nnoremap [;] <Nop>
    nnoremap ;; ;
    nmap ; [;]

    nnoremap [s] <Nop>
    nnoremap s <Nop>
    nmap s [s]
" }}}

" classic commands {{{
    " clipboard " {{{
    set clipboard+=unnamed " Enable to use clipboard
    nnoremap ]f :<c-u>set clipboard+=unnamed<cr>
    nnoremap [f :<c-u>set clipboard-=unnamed<cr>
    " }}}

    " show all concealed character
    nnoremap [;]f :<c-u>setlocal conceallevel=0<cr>

    " move middle of the current line
    nnoremap [s]m :<C-u>call cursor(0,strlen(getline("."))/2)<CR>

    " modes short cut
    nnoremap [;]t :<C-u>terminal<cr>

    " 開いているファイルのカレントディレクトリを開く
    nnoremap [m]t :sp<cr>:edit %:h<tab><cr>

    " カーソル下の単語をハイライトする
    nnoremap <silent> <Space><Space> "zyiw:let @/ = '\<' . @z . '\>'<CR>:set hlsearch<CR>

    " カーソル下の単語をハイライトしてから置換する
    nnoremap # <Space><Space>:%s/<C-r>///g<Left><Left>

    " カーソル下の単語をGoogleで検索する
    function! s:search_by_google()
        let line = line(".")
        let col  = col(".")
        let searchWord = expand("<cword>")
        if searchWord  != ''
            execute 'read !open https://www.google.co.jp/search\?q\=' . searchWord
            execute 'call cursor(' . line . ',' . col . ')'
        endif
    endfunction
    command! SearchByGoogle call s:search_by_google()
    nnoremap <silent> <Space>g :SearchByGoogle<CR>

    " nerdtree
    map <space>s :<c-u>NERDTreeToggle<CR>

    " 日本語
    nnoremap あ a
    nnoremap い i

    " bracket
    map <tab> %

    " 移動
    nnoremap H ^
    nnoremap L g_

    " 読み込み
    nnoremap [m]s :<C-u>source %<cr>

    " マーク
    nnoremap <silent> <leader>hh :execute 'match  InterestingWord1 /\<<c-r><c-w>\>/'<cr>
    nnoremap <silent> <leader>h1 :execute 'match  InterestingWord1 /\<<c-r><c-w>\>/'<cr>
    nnoremap <silent> <leader>h2 :execute '2match InterestingWord2 /\<<c-r><c-w>\>/'<cr>
    nnoremap <silent> <leader>h3 :execute '3match InterestingWord3 /\<<c-r><c-w>\>/'<cr>

    " open file
    nnoremap [m]v :vi<space>

    " color scheme
    nnoremap [,]c :<c-u>Unite colorscheme -auto-preview<cr>

    " Grep {{{
        " same meaning as ``:vim {pattern} {file} | cw``
        augroup GrepCmd
            autocmd!
            autocmd QuickFixCmdPost *grep* cwindow  " add ``| cw`` automatically
        augroup END
        " depend on vim-unimpaired {{{
        nnoremap [q :cprevious<CR>   " 前へ
        nnoremap ]q :cnext<CR>       " 次へ
        nnoremap [Q :<C-u>cfirst<CR> " 最初へ
        nnoremap ]Q :<C-u>clast<CR>  " 最後へ
        " }}}
    " }}}
" }}}

" split windows {{{
    nnoremap [s]j <C-w>j
    nnoremap [s]k <C-w>k
    nnoremap [s]l <C-w>l
    nnoremap [s]h <C-w>h
    nnoremap [s]J <C-w>J
    nnoremap [s]K <C-w>K
    nnoremap [s]L <C-w>L
    nnoremap [s]H <C-w>H
    nnoremap [s]n gt
    nnoremap [s]p gT
    nnoremap [s]r <C-w>r
    nnoremap [s]= <C-w>=
    nnoremap [s]w <C-w>w
    nnoremap [s]o <C-w>_<C-w>|
    nnoremap [s]O <C-w>=
    nnoremap [s]N :<C-u>bn<CR>
    nnoremap [s]P :<C-u>bp<CR>
    nnoremap [s]t :<C-u>tabnew<CR>
    nnoremap [s]T :<C-u>Unite tab<CR>
    nnoremap [s]s :<C-u>sp<CR>
    nnoremap [s]v :<C-u>vs<CR>
    nnoremap [s]q :<C-u>q<CR>
    nnoremap [s]Q :<C-u>bd<CR>
    nnoremap [s]b :<C-u>Unite buffer_tab -buffer-name=file<CR>
    nnoremap [s]B :<C-u>Unite buffer -buffer-name=file<CR>

    " 下部に幅10のコマンドラインを生成
    nnoremap [s]; :<c-u>sp<cr><c-w>J:<c-u>res 10<cr>:<C-u>terminal<cr>:<c-u>setlocal noequalalways<cr>i

    " delte the current buffer
    nnoremap [s]d :<C-u>bd<CR>
" }}}

" folding {{{
    " toggle foldmethod
    nnoremap <space>ff :call <SID>ToggleFold()<CR>
    function! s:ToggleFold()
        if &foldmethod == 'indent'
            let &l:foldmethod = 'marker'
        else
            let &l:foldmethod = 'indent'
        endif
        echo 'foldmethod is now ' . &l:foldmethod
    endfunction

    " NOTE: 備忘録
    " 折りたたみと展開（カーソル位置の要素に対して）
    " zc  -- 折りたたみ (Close one fold under the cursor)
    " zo  -- 展開（一段階）(Open one fold under the cursor)
    " zO  -- 展開（すべて）(Open all folds under the cursor recursively)
    "
    " 折りたたみと展開（ファイル全体の要素に対して）
    " zm -- 折りたたみ（一段階） (Fold more)
    " zM -- 折りたたみ（すべて） (Close all folds)
    " zr -- 展開（一段階） (Reduce folding)
    " zR -- 展開（すべて） (Open all folds)
    "
    " 折りたたみ単位でジャンプ
    " zj -- move to the next fold
    " zk -- move to the previous fold

    nnoremap <silent> <space>j zj
    nnoremap <silent> <space>k zk

    nnoremap <silent> <space>h zc    " 折りたたみ
    nnoremap <silent> <space>l zO    " 展開

    nnoremap <silent> <space>H zM    " 折りたたみ
    nnoremap <silent> <space>L zR    " 展開

    nnoremap <silent> <space>o zMzv  " 自分以外とじる
" }}}

" Destructive commands {{{
    " I don't recommend using this command without deep understanding.
    " This command has a lot of side effects.

    " Remove trailing whitespace
    command RemoveTrailingWhitespace :%s/\s\+$//ge
" }}}

" mac only!!!!!!!!!!!!!! {{{
    " Search meaning of the current word.
    nnoremap [,]? :!open dict://<cword><CR>
" }}}
