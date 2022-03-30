scriptencoding utf-8

" " dcc {{{
" call ddc#custom#patch_global('sources', ['skkeleton'])
" call ddc#custom#patch_global('sourceOptions', {
"     \   '_': {
"     \     'matchers': ['matcher_head'],
"     \     'sorters': ['sorter_rank']
"     \   },
"     \   'skkeleton': {
"     \     'mark': 'skkeleton',
"     \     'matchers': ['skkeleton'],
"     \     'sorters': [],
"     \     'minAutoCompleteLength': 2,
"     \   },
"     \ })
" call ddc#enable()
" " }}}

" " skkeleton {{{
" call skkeleton#config({
"     \ 'globalJisyo': '/Users/cassin/.config/nvim/data/skk/dict/SKK-JISYO.XL',
"     \ 'completionRankFile': '/Users/cassin/.config/nvim/data/skk/rank.json',
"     \ 'eggLikeNewline': v:true,
"     \ 'registerConvertResult': v:true,
"     \ })
" " }}}

" submode start {{{
    " resize window
    call submode#enter_with('bufmove', 'n', '', 's>', '<C-w>>')
    call submode#enter_with('bufmove', 'n', '', 's<', '<C-w><')
    call submode#enter_with('bufmove', 'n', '', 's+', '<C-w>+')
    call submode#enter_with('bufmove', 'n', '', 's-', '<C-w>-')
    call submode#map('bufmove', 'n', '', '>', '<C-w>>')
    call submode#map('bufmove', 'n', '', '<', '<C-w><')
    call submode#map('bufmove', 'n', '', '+', '<C-w>+')
    call submode#map('bufmove', 'n', '', '-', '<C-w>-')
" }}}

" " coc.nvim {{{
"     " if hidden is not set, TextEdit might fail.
"     set hidden
" 
"     " Some servers have issues with backup files, see #649
"     set nobackup
"     set nowritebackup
" 
"     " Better display for messages
"     set cmdheight=2
" 
"     " You will have bad experience for diagnostic messages when it's default 4000.
"     set updatetime=300
" 
"     " don't give |ins-completion-menu| messages.
"     set shortmess+=c
" 
"     " Always show the signcolumn, otherwise it would shift the text each time
"     " diagnostics appear/become resolved.
"     if has("patch-8.1.1564")
"         " Recently vim can merge signcolumn and number column into one
"         set signcolumn=number
"     else
"         set signcolumn=yes
"     endif
" 
"     " Use tab for trigger completion with characters ahead and navigate.
"     " Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
"     inoremap <silent><expr> <TAB>
"         \ pumvisible() ? "\<C-n>" :
"         \ <SID>check_back_space() ? "\<TAB>" :
"         \ coc#refresh()
"     inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
" 
"     function! s:check_back_space() abort
"         let col = col('.') - 1
"         return !col || getline('.')[col - 1]  =~# '\s'
"     endfunction
" 
"     " Use K to show documentation in preview window
"     nnoremap <silent> K :call <SID>show_documentation()<CR>
" 
"     function! s:show_documentation()
"         if (index(['vim','help'], &filetype) >= 0)
"             execute 'h '.expand('<cword>')
"         else
"             call CocAction('doHover')
"         endif
"     endfunction
" 
"     "ノーマルモードで
"     "スペース2回でCocList
"     "nmap <silent> <space>l :<C-u>CocList<cr>
"     "スペースhでHover
"     nmap <silent> <space>i :<C-u>call CocAction('doHover')<cr>
"     "スペースdfでDefinition
"     nmap <silent> <space>df <Plug>(coc-definition)
"     "スペースrfでReferences
"     nmap <silent> <space>rf <Plug>(coc-references)
"     "スペースrnでRename
"     nmap <silent> <space>rn <Plug>(coc-rename)
"     "スペースfmtでFormat
"     nmap <silent> <space>fmt <Plug>(coc-format)
"     " Fix autofix problem of current line
"     nmap <silent> <space>qf  <Plug>(coc-fix-current)
" " }}}

" ultisnipets {{{
    let g:UltiSnipsSnippetsDir="~/.config/nvim/UltiSnips"

    " Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
    let g:UltiSnipsExpandTrigger="<tab>"
    let g:UltiSnipsJumpForwardTrigger="<tab>"
    let g:UltiSnipsJumpBackwardTrigger="<space>n"

    " If you want :UltiSnipsEdit to split your window.
    let g:UltiSnipsEditSplit="horizontal"
" }}}

" vim-lsp {{{
    "  Rust
    if executable('rls')
        au User lsp_setup call lsp#register_server({
            \ 'name': 'rls',
            \ 'cmd': {server_info->['rustup', 'run', 'stable', 'rls']},
            \ 'workspace_config': {'rust': {'clippy_preference': 'on'}},
            \ 'whitelist': ['rust'],
            \ })
    endif

    " Python
    "if executable('pyls')
    "    au User lsp_setup call lsp#register_server({
    "        \ 'name': 'pyls',
    "        \ 'cmd': {server_info->['pyls']},
    "        \ 'whitelist': ['python'],
    "        \ })
    "endif

    set completeopt+=menuone "候補が一つでも実行
" }}}

" neosnippet {{{
    " Plugin key-mappings.
    " Note: It must be "imap" and "smap".  It uses <Plug> mappings.
    " imap <C-k> <Plug>(neosnippet_expand_or_jump)
    " smap <C-k> <Plug>(neosnippet_expand_or_jump)
    " xmap <C-k> <Plug>(neosnippet_expand_target)

    " SuperTab like snippets behavior.
    " Note: It must be "imap" and "smap".  It uses <Plug> mappings.
    "imap <expr><TAB>
    " \ pumvisible() ? "\<C-n>" :
    " \ neosnippet#expandable_or_jumpable() ?
    " \    "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
    smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
    \ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

    " For conceal markers.
    if has('conceal')
      set conceallevel=2 concealcursor=niv
    endif
" }}}
