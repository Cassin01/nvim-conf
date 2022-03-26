" ハイライトグループの確認 {{{
    " Note: :SyntaxInfo でカーソルの下にあるコードのハイライトグループがわかる
    function! s:get_syn_id(transparent)
      let synid = synID(line("."), col("."), 1)
      if a:transparent
        return synIDtrans(synid)
      else
        return synid
      endif
    endfunction
    function! s:get_syn_attr(synid)
      let name = synIDattr(a:synid, "name")
      let ctermfg = synIDattr(a:synid, "fg", "cterm")
      let ctermbg = synIDattr(a:synid, "bg", "cterm")
      let guifg = synIDattr(a:synid, "fg", "gui")
      let guibg = synIDattr(a:synid, "bg", "gui")
      return {
            \ "name": name,
            \ "ctermfg": ctermfg,
            \ "ctermbg": ctermbg,
            \ "guifg": guifg,
            \ "guibg": guibg}
    endfunction
    function! s:get_syn_info()
      let baseSyn = s:get_syn_attr(s:get_syn_id(0))
      echo "name: " . baseSyn.name .
            \ " ctermfg: " . baseSyn.ctermfg .
            \ " ctermbg: " . baseSyn.ctermbg .
            \ " guifg: " . baseSyn.guifg .
            \ " guibg: " . baseSyn.guibg
      let linkedSyn = s:get_syn_attr(s:get_syn_id(1))
      echo "link to"
      echo "name: " . linkedSyn.name .
            \ " ctermfg: " . linkedSyn.ctermfg .
            \ " ctermbg: " . linkedSyn.ctermbg .
            \ " guifg: " . linkedSyn.guifg .
            \ " guibg: " . linkedSyn.guibg
    endfunction
    command! SyntaxInfo call s:get_syn_info()
    " nnoremap <buffer> <silent> ,n :SyntaxInfo<CR>
    nnoremap <silent> ,n :SyntaxInfo<CR>
" }}}

" https://zenn.dev/kawarimidoll/articles/cf6caaa7602239
" {{{
command! -nargs=+ -complete=highlight MergeHighlight call s:MergeHighlight(<q-args>)
function! s:MergeHighlight(args) abort
  let l:args = split(a:args)
  if len(l:args) < 2
    echoerr '[MergeHighlight] At least 2 arguments are required.'
    echoerr 'New highlight name and source highlight names.'
    return
  endif

  " skip 'links' and 'cleared'
  execute 'highlight' l:args[0] l:args[1:]
      \ ->map({_, val -> substitute(execute('highlight ' . val),  '^\S\+\s\+xxx\s', '', '')})
      \ ->filter({_, val -> val !~? '^links to' && val !=? 'cleared'})
      \ ->join()
endfunction
" }}}
