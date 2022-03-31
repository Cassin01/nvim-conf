function! s:incsearch_config(...) abort
return incsearch#util#deepextend(deepcopy({
            \   'modules': [incsearch#config#easymotion#module({'overwin': 1})],
            \   'keymap': { "\<CR>": '<Over>(easymotion)' },
            \   'is_expr': 0 }), get(a:000, 1, {}))
endfunction
noremap <silent><expr> /  incsearch#go(<SID>incsearch_config({}))
noremap <silent><expr> ?  incsearch#go(<SID>incsearch_config({'command': '?'}))
noremap <silent><expr> g/ incsearch#go(<SID>incsearch_config({'is_stay': 1}))
