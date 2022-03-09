if !exists("g:cod")
    let g:cod = {}
    let g:cod["char"] = 0
    let g:cod["move"] = 0
    let g:cod["coin"] = 0
    let g:cod["seed"] = srand()
    let g:cod["move_c"] = 0
    let g:cod["char_c"] = 0
end

function! s:char()
    let g:cod["char"] = g:cod["char"] + 1
    let g:cod["char_c"] = g:cod["char_c"] + 1
endfunction

function! s:move()
    let g:cod["move"] = g:cod["move"] + 1
    let g:cod["move_c"] = g:cod["move_c"] + 1
endfunction

function! s:compute()
   " 0~99
   let p = rand(g:cod["seed"]) % 100

   let do = v:false
   if p < 50 * g:cod["char_c"] / g:cod["move_c"]
       let do = v:true
   endif

   if do
       return g:cod["char_c"]
   else
       return 0
   endif
endfunction

function! s:show()
    echo printf("inserted char: %d, Moved time: %d", g:cod["char"], g:cod["move"])
    echo printf("coin: %d", g:cod["coin"])
endfunction

function! s:bet()
    let g:cod["coin"] = g:cod["coin"] + s:compute()
    echo g:cod["coin"]
    let g:cod["char_c"] = 0
    let g:cod["move_c"] = 0
endfunction

"augroup counter_inputa
"    autocmd!
"augroup

autocmd InsertCharPre * call s:char()
autocmd CursorMoved * call s:move()
command! CodBet call s:bet()
command! CodShow call s:show()

nmap <space>bb :CodBet<cr>
nmap <space>bs :CodShow<cr>
