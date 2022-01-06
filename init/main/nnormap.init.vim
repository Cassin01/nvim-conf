scriptencoding utf-8

" Initialization {{{
    " プレフィックスを
    " ```
    " nnoremap [m] <Nop>
    " nnoremap mm m
    " nmap m [m]
    " ```
    " と記述していた．
    " また，
    " which-keyを
    " ``nnoremap <silent> m :<c-u>WhichKey '[m]'<CR>[]``
    " と記述していた.
    "
    " vim-tex プラグインの``[m``というコマンド,
    " which-key プラグインと相性が良くなかった.
    " 従って以下の方法で書く.
    " https://thinca.hatenablog.com/entry/q-as-prefix-key-in-vim

    " m単体のキーがあった場合に停止する.
    nnoremap m <Nop>
    nnoremap mm m
    nnoremap s <Nop>
    nnoremap ss s
    nnoremap , <Nop>
    nnoremap ,, ,
    nnoremap ; <Nop>
    nnoremap ;; ;
    nnoremap <space> <Nop>
" }}}

" コマンド上塗り系 {{{
" 行が折り返し表示されていた場合, 行単位ではなく表示行単位でカーソルを移動する
nnoremap j gj
nnoremap k gk
nnoremap <down> gj
nnoremap <up> gk
" }}}

" classic commands {{{
    " clipboard " {{{
    set clipboard+=unnamed " Enable to use clipboard
    nnoremap ]f :<c-u>set clipboard+=unnamed<cr>
    nnoremap [f :<c-u>set clipboard-=unnamed<cr>
    " }}}

    " show all concealed character
    nnoremap ]x :<c-u>setlocal conceallevel=1<cr>
    nnoremap [x :<c-u>setlocal conceallevel=0<cr>

    " move middle of the current line
    nnoremap sm :<C-u>call cursor(0,strlen(getline("."))/2)<CR>

    " modes short cut
    nnoremap ;t :<C-u>terminal<cr>

    " 開いているファイルのカレントディレクトリを開く
    nnoremap mt :sp<cr>:edit %:h<tab><cr>

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

    " NERDTree {{{
    nnoremap <space>s :<c-u>NERDTreeToggle<CR>

    " view the current buffer in NERDtree
    nnoremap <space>c :<c-u>NERDTreeFind<cr>
    " }}}

    " 日本語
    nnoremap あ a
    nnoremap い i

    " bracket
    nnoremap <tab> %

    " 移動
    nnoremap H ^
    nnoremap L $
"    nnoremap L g_

    " 読み込み
    nnoremap ms :<C-u>source %<cr>

    " マーク
    nnoremap <silent> <leader>hh :execute 'match  InterestingWord1 /\<<c-r><c-w>\>/'<cr>
    nnoremap <silent> <leader>h1 :execute 'match  InterestingWord1 /\<<c-r><c-w>\>/'<cr>
    nnoremap <silent> <leader>h2 :execute '2match InterestingWord2 /\<<c-r><c-w>\>/'<cr>
    nnoremap <silent> <leader>h3 :execute '3match InterestingWord3 /\<<c-r><c-w>\>/'<cr>

    " open file
    nnoremap mv :vi<space>

    " markdownの目次取得 {{{
    function! s:get_toc() abort
        let lines=getline(1, '$')
        let toc = []
        for line in lines
            if line =~ '#\+ .\+'
                let tmp = substitute(line, "#", "    ", "g")
                call add(toc, tmp)
            endif
        endfor
        "echo join(toc, "\n")
        "call s:sessions()
        "return join(toc, "\n")
        return toc
    endfunction
    let s:session_list_buffer = 'SESSIONS'

    function! s:get_toc_sessions() abort
        let files = s:get_toc()
        if empty(files) == 'tex'
            return
        endif

        " バッファが存在している場合
        if bufexists(s:session_list_buffer)
            " バッファがウィンドウに表示されている場合は`win_gotoid`でウィンドウに移動します
            let winid = bufwinid(s:session_list_buffer)
            if winid isnot# -1
                call win_gotoid(winid)

                " バッファがウィンドウに表示されていない場合は`sbuffer`で新しいウィンドウを作成してバッファを開きます
            else
                execute 'vert' 'sbuffer' s:session_list_buffer
            endif

        else
            " バッファが存在していない場合は`new`で新しいバッファを作成します
            " execute 'new' s:session_list_buffer
            setlocal splitright
            execute 'vsplit' s:session_list_buffer

            " バッファの種類を指定します
            " ユーザが書き込むことはないバッファなので`nofile`に設定します
            " 詳細は`:h buftype`を参照してください
            set buftype=nofile

            " 1. セッション一覧のバッファで`q`を押下するとバッファを破棄
            " 2. `Enter`でセッションをロード
            " の2つのキーマッピングを定義します。
            "
            " <C-u>と<CR>はそれぞれコマンドラインでCTRL-uとEnterを押下した時の動作になります
            " <buffer>は現在のバッファにのみキーマップを設定します
            " <silent>はキーマップで実行されるコマンドがコマンドラインに表示されないようにします
            " <Plug>という特殊な文字を使用するとキーを割り当てないマップを用意できます
            " ユーザはこのマップを使用して自分の好きなキーマップを設定できます
            "
            " \ は改行するときに必要です
            nnoremap <silent> <buffer>
                        \ <Plug>(session-close)
                        \ :<C-u>bwipeout!<CR>

            nnoremap <silent> <buffer>
                        \ <Plug>(session-open)
                        \ :<C-u>call session#load_session(trim(getline('.')))<CR>

            " <Plug>マップをキーにマッピングします
            " `q` は最終的に :<C-u>bwipeout!<CR>
            " `Enter` は最終的に :<C-u>call session#load_session()<CR>
            " が実行されます
            nmap <buffer> q <Plug>(session-close)
            nmap <buffer> <CR> <Plug>(session-open)
        endif

        " セッションファイルを表示する一時バッファのテキストをすべて削除して、取得したファイル一覧をバッファに挿入します
        %delete _
        "call setline(1, files)
        let i = 0
        while i < len(files)
            let item = files[i]
            call setline(i+1, item)
            let i = i + 1
        endwhile
    endfunction
    command! GetTOC :call s:get_toc_sessions()
    " }}}

    " reload init.vim
    command! ReloadInitVim :so $MYVIMRC

    " ファイル名表示
    command! FileName :echo expand("%:t")

    " ファイルパス表示
    command! FilePath :echo expand("%:p")

    " python呼び出しの練習に使用(使ってない) {{{
let s:script_dir = fnamemodify(resolve(expand('<sfile>', ':p')), ':h')
function! s:Convert30()
py3 << EOF
import vim
script_dir = vim.eval('s:script_dir')
sys.path.insert(0, script_dir)
import parser0
def convert():
    out = parser0.convert2(vim.current.line)
    vim.current.line = out
convert()
EOF
endfunction

com! Conv30 call s:Convert30()
nnoremap ,kkk :Conv30<CR>
    " }}}

    " " a note using floating window {{{
    " "TODO:タブでカーソル移動できるようにする．
    " function! s:parser10(txt) " 作りかけ
    "     return s:retf10(a:txt, "")
    " endfunction

    " " reft10(iter:入力値, ret:返り値)
    " function! s:retf10(iter, ret)
    "     if strlen(a:iter) == 0
    "         return a:ret
    "     endif
    "     let l:element = a:iter[0]
    "     if l:element == '$'
    "         let l:buf = []
    "         for l:e in split(a:iter, '\zs')
    "             let l:buf = add(l:buf, l:e)
    "             if l:e == '}'
    "                 break
    "             endif
    "         endfor
    "         if matchstr(join(l:buf, ''), '\$\\{[0-9]+:.+\\}') >= 0
    "             return s:retf10(a:iter[len(l:buf):], a:ret)
    "         endif
    "     endif
    "     return s:retf10(a:iter[1:], a:ret . l:element)
    " endfunction
    " function! s:t20_exit_buf()
    "     let ctext =  "\\" . s:parser10(split(getline('.'), ',')[0])
    "     execute  "quit"
    "     execute "normal! a" . ctext . "\<Esc>"
    " endfunction
    " function! s:m_math_glossary()
    "     let buf = nvim_create_buf(v:false, v:true)
    "     call nvim_buf_set_lines(buf, 0, 0, v:true, map(readfile(glob('~/.config/nvim/latex_commands.csv')), {_, a->substitute(a, '"', '', 'g')}) )
    "     let opts = {'relative': 'cursor', 'width': 30, 'height': 15, 'col': 0,
    "                 \ 'row': 1, 'anchor': 'NW', 'style': 'minimal'}
    "     let win = nvim_open_win(buf, 1, opts)
    "     " optional: change highlight, otherwise Pmenu is used
    "     call nvim_win_set_option(win, 'winhl', 'Normal:MMathGlossary')

    "     command! TCommands call s:t20_exit_buf()
    "     nnoremap <buffer> <silent> ,t :TCommands<CR>
    " endfunction

    " command! TexCommands :call s:m_math_glossary()
    " nnoremap <silent> ,t :TexCommands<CR>
    " " }}}

    " color scheme
    nnoremap ,c :<c-u>Unite colorscheme -auto-preview<cr>

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
    nnoremap sj <C-w>j
    nnoremap sk <C-w>k
    nnoremap sl <C-w>l
    nnoremap sh <C-w>h
    nnoremap sJ <C-w>J
    nnoremap sK <C-w>K
    nnoremap sL <C-w>L
    nnoremap sH <C-w>H
    nnoremap sn gt
    nnoremap sp gT
    nnoremap sr <C-w>r
    nnoremap s= <C-w>=
    nnoremap sw <C-w>w
    nnoremap so <C-w>_<C-w>|
    nnoremap sO <C-w>=
    nnoremap sN :<C-u>bn<CR>
    nnoremap sP :<C-u>bp<CR>
    nnoremap st :<C-u>tabnew<CR>
    nnoremap sT :<C-u>Unite tab<CR>
    nnoremap ss :<C-u>sp<CR>
    nnoremap sv :<C-u>vs<CR>
    nnoremap sq :<C-u>q<CR>
    nnoremap sQ :<C-u>bd<CR>
    nnoremap sb :<C-u>Unite buffer_tab -buffer-name=file<CR>
    nnoremap sB :<C-u>Unite buffer -buffer-name=file<CR>

    " 下部に幅10のコマンドラインを生成
    nnoremap s; :<c-u>sp<cr><c-w>J:<c-u>res 10<cr>:<C-u>terminal<cr>:<c-u>setlocal noequalalways<cr>i

    " delte the current buffer
    nnoremap sd :<C-u>bd<CR>
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
    command! RemoveTrailingWhitespace :%s/\s\+$//ge

    " Replace tab with space
    command! ReplaceTabWithSpace :%s/\t/ /g
" }}}

" Shell Command execution {{{
   " " Compile Latex
   " function! s:compile_latex()
   "     if expand("%") == 'l02.tex' || expand("%") == 'l03.tex'
   "         function! s:OnEvent(job_id, data, event) dict
   "             if a:event == 'stdout'
   "                 let str = self.shell.' stdout: '.join(a:data)
   "             elseif a:event == 'stderr'
   "                 let str = self.shell.' stderr: '.join(a:data)
   "                 echo str
   "             else
   "                 let str = self.shell.' exited'
   "             endif
   "         endfunction
   "         let s:callbacks = {
   "                     \ 'on_stdout': function('s:OnEvent'),
   "                     \ 'on_stderr': function('s:OnEvent'),
   "                     \ 'on_exit': function('s:OnEvent')
   "                     \ }
   "         let s:job1 = jobstart(['zsh', '-c', 'lualatex ' . expand('%:r')], extend({'shell': 'shell 1'}, s:callbacks))
   "     endif
   " endfunction

   " command! CompileLatex call s:compile_latex()

   "   "function! s:reload_ctags()
   "   "    if expand('%:e') == 'rs'
   "   "        let fe =  system('ctags', '-R')
   "   "        if v:shell_error != 0
   "   "            echo fe
   "   "        endif
   "   "    else
   "   "        echo expand('%:e')
   "   "        echo 'Error: 拡張子が`rs`でないのでコンパイルできません.'
   "   "    endif
   "   "endfunction

   "   augroup FlowWriteFile
   "       au!
   "       autocmd BufWritePost *.tex :call s:compile_latex()
   "       "autocmd BufWritePost *.rs :call s:reload_ctags()
   "   augroup END
" }}}

" Search meaning of the current word.
if has("mac")
    nnoremap ,? :!open dict://<cword><CR>
endif
