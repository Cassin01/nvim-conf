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
  endfor
  return l:res
endfunction

function! s:term_list()
  let l:blist = getbufinfo({'bufloaded': 1, 'buflisted': 1})
  let l:res = []
  for l:item in l:blist
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
  let l:terms = s:term_list()
  if empty(l:terms)
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
    endif
  endif
endfunction

inoremap <c-@> <cmd>:call ToggleTerminal()<cr>
nnoremap <c-@> <cmd>:call ToggleTerminal()<cr>
tnoremap <c-@> <cmd>:call ToggleTerminal()<cr>
