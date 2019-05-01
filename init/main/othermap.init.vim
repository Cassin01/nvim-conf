scriptencoding utf-8

" nerdtree
map <C-n> :NERDTreeToggle<CR>

" insert mode
inoremap <silent> <C-f> <right>
inoremap <silent> <C-b> <left>

" 括弧補完
inoremap ( ()<left>
" 上の例外処理: の後に続けて)を押したとき
inoremap <expr> )  strpart(getline('.'), col('.')-1, 1) == ")" ? "\<Right>" : ")"

" 括弧補完
inoremap [ []<left>
" 上の例外処理: の後に続けて)を押したとき
inoremap <expr> ]  strpart(getline('.'), col('.')-1, 1) == "]" ? "\<Right>" : "]"

" quotation補完
inoremap " ""<left>
inoremap ' ''<left>

augroup FolowFile
    autocmd!
    autocmd BufRead,BufNewFile *.c    inoremap {<enter> {}<left><cr><cr><up><tab>
    autocmd BufRead,BufNewFile *.dart inoremap {<enter> {}<left><cr><cr><up><tab>
    autocmd BufRead,BufNewFile *.cpp  inoremap {<enter> {}<left><cr><cr><up><tab>
    autocmd BufRead,BufNewFile *.rs   inoremap {<enter> {}<left><cr><cr><up><tab>
    autocmd BufRead,BufNewFile *.go   inoremap {<enter> {}<left><cr><cr><up><tab>
augroup END

" terminal mode
tnoremap <silent> <esc> <C-\><C-n>
