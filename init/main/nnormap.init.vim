scriptencoding utf-8

nnoremap mp :<c-u>set clipboard+=unnamed<cr>
nnoremap mm :<c-u>set clipboard-=unnamed<cr>

" move middle of the current line
nnoremap sm :<C-u>call cursor(0,strlen(getline("."))/2)<CR>

" modes short cut
nnoremap s<space> :<C-u>terminal<cr>

" 開いているファイルのカレントディレクトリを開く
nnoremap <C-k> :sp<cr>:edit %:h<tab><cr>

" カーソル下の単語をハイライトする
nnoremap <silent> <Space><Space> "zyiw:let @/ = '\<' . @z . '\>'<CR>:set hlsearch<CR>

" カーソル下の単語をハイライトしてから置換する
nmap # <Space><Space>:%s/<C-r>///g<Left><Left>

" nerdtree
map <C-l> :NERDTreeToggle<CR>

" 日本語
nnoremap あ a
nnoremap い i

" split windows
nnoremap s <Nop>
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

" ---------------------------
" folding start
" ---------------------------
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
nmap <silent> <space>j zj
nmap <silent> <space>k zk

nmap <silent> <space>h zc   " 折りたたみ
nmap <silent> <space>l zO   " 展開

nmap <silent> <space>H zM   " 折りたたみ
nmap <silent> <space>L zR   " 展開

nmap <silent> <space>o zMzv " 自分以外とじる
" ---------------------------
" folding end
" ---------------------------

" ---------------------------
"  mac only!!!!!!!!!!!!!!!!!!
"  start
" ---------------------------
nnoremap ,? :!open dict://<cword><CR>
" ---------------------------
"  end
"  mac only!!!!!!!!!!!!!!!!!!
" ---------------------------
