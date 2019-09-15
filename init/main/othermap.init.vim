scriptencoding utf-8

" nerdtree
map <C-l> :NERDTreeToggle<CR>

" insert mode
inoremap <silent><C-b> <right>
inoremap <silent><C-k> <up>
inoremap <silent><C-l> <down>

" ---- 括弧補完 ----
inoremap (( (
inoremap {{ {
inoremap [[ [
inoremap ( ()<left>
inoremap { {}<left>
inoremap [ []<left>
" 例外処理: の後に続けて)を押したとき
inoremap <expr> )  strpart(getline('.'), col('.')-1, 1) == ")" ? "\<Right>" : ")"
inoremap <expr> ]  strpart(getline('.'), col('.')-1, 1) == "]" ? "\<Right>" : "]"
inoremap <expr> }  strpart(getline('.'), col('.')-1, 1) == "}" ? "\<Right>" : "}"
" ------------------

" quotation補完
inoremap " ""<left>
inoremap ' ''<left>

augroup FolowFile
    au!
    au BufRead,BufNewFile *.c    inoremap {<enter> {}<left><cr><cr><up><tab>
    au BufRead,BufNewFile *.dart inoremap {<enter> {}<left><cr><cr><up><tab>
    au BufRead,BufNewFile *.cpp  inoremap {<enter> {}<left><cr><cr><up><tab>
    au BufRead,BufNewFile *.rs   inoremap {<enter> {}<left><cr><cr><up><tab>
    au BufRead,BufNewFile *.go   inoremap {<enter> {}<left><cr><cr><up><tab>
    au BufRead,BufNewFile *.css  inoremap {<enter> {}<left><cr><cr><up><tab>
    au BufRead,BufNewFile *.js   inoremap {<enter> {}<left><cr><cr><up><tab>
    au BufRead,BufNewFile *.php  inoremap {<enter> {}<left><cr><cr><up><tab>
    au BufRead,BufNewFile *.html inoremap {<enter> {}<left><cr><cr><up><tab>
    au BufRead,BufNewFile *.c    inoremap /* <kDivide><kMultiply><space><space><kMultiply><kDivide><left><left><left>
    au BufRead,BufNewFile *.rs   inoremap /* <kDivide><kMultiply><space><space><kMultiply><kDivide><left><left><left>
augroup END

" terminal mode
tnoremap <silent> <esc> <C-\><C-n>

augroup FolowTerm
    au!
    au TermOpen * set nonumber
augroup END
