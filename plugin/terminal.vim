" Ref: mattn on vim.jp
function! GetActivebuffers()
  " the result is a list of buffers
  " use join() when a single string is needed
  " :exec '!cat' join(GetActivebuffers())
  let l:blist = getbufinfo({'bufloaded': 1, 'buflisted': 1})
  let l:res = []
  for l:item in l:blist
    if empty(l:item.name) || l:item.hidden
      continue
    endif
    call add(l:res, shellescape(l:item.name))
    call luaeval('print(vim.inspect(_A))', l:item)
  endfor
  return l:res
endfunction

function! s:term_list()
  let l:blist = getbufinfo({'bufloaded': 1, 'buflisted': 1})
  let l:res = []
  for l:item in l:blist
    " if empty(l:item.name) " || l:item.hidden
    "   continue
    " endif
    if empty(l:item.variables)
      continue
    endif
    if ! has_key(l:item.variables, "terminal_job_id")
      continue
    endif
    call add(l:res, l:item.bufnr)
  endfor
  return l:res
endfunction

function! ToggleTerminal() abort
  let l:terms = s:term_list() " TODO add term_list()
  if empty(l:terms)
    " TODO fix win size
    " botright terminal
    split
    execute "normal! \<c-w>J"
    resize 10
    terminal
  else
    let l:wins = win_findbuf(l:terms[0])
    if empty(l:wins)
      botright 10split
      execute 'buffer' l:terms[0]
    else
      call nvim_win_hide(l:wins[0])
      " call win_execute(l:wins[0], 'hide')
    endif
  endif
endfunction

inoremap <c-2> <cmd>:call ToggleTerminal()<cr>
nnoremap <c-2> <cmd>:call ToggleTerminal()<cr>
tnoremap <c-2> <cmd>:call ToggleTerminal()<cr>

autocmd! TermOpen * startinsert
