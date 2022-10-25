function! s:init_fern() abort
    setlocal nonumber
    setlocal norelativenumber
    " Define NERDTree like mappings
    nmap <buffer> o <Plug>(fern-action-open:edit)
    nmap <buffer> go <Plug>(fern-action-open:edit)<C-w>p
    nmap <buffer> t <Plug>(fern-action-open:tabedit)
    nmap <buffer> T <Plug>(fern-action-open:tabedit)gT
    nmap <buffer> i <Plug>(fern-action-open:split)
    nmap <buffer> gi <Plug>(fern-action-open:split)<C-w>p
    nmap <buffer> s <Plug>(fern-action-open:vsplit)
    nmap <buffer> gs <Plug>(fern-action-open:vsplit)<C-w>p
    nmap <buffer> ma <Plug>(fern-action-new-path)
    nmap <buffer> mm <Plug>(fern-action-rename)
    nmap <buffer> P gg

    nmap <buffer> C <Plug>(fern-action-enter)
    nmap <buffer> u <Plug>(fern-action-leave)
    nmap <buffer> r <Plug>(fern-action-reload)
    nmap <buffer> R gg<Plug>(fern-action-reload)<C-o>
    nmap <buffer> cd <Plug>(fern-action-cd)
    nmap <buffer> CD gg<Plug>(fern-action-cd)<C-o>

    nmap <buffer> I <Plug>(fern-action-hidden-toggle)

    nmap <buffer> q :<C-u>quit<CR>

    nmap <buffer><expr>
                \ <Plug>(fern-my-expand-or-enter)
                \ fern#smart#drawer(
                \   "\<Plug>(fern-open-or-expand)",
                \   "\<Plug>(fern-open-or-enter)",
                \ )
    nmap <buffer><expr>
                \ <Plug>(fern-my-collapse-or-leave)
                \ fern#smart#drawer(
                \   "\<Plug>(fern-action-collapse)",
                \   "\<Plug>(fern-action-leave)",
                \ )
    nmap <buffer><nowait> l <Plug>(fern-my-expand-or-enter)
    nmap <buffer><nowait> h <Plug>(fern-my-collapse-or-leave)
endfunction

augroup fern-custom
    autocmd! *
    autocmd FileType fern call s:init_fern()
augroup END
