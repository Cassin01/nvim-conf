scriptencoding utf-8

" ██╗███╗   ██╗██╗████████╗██╗   ██╗██╗███╗   ███╗
" ██║████╗  ██║██║╚══██╔══╝██║   ██║██║████╗ ████║
" ██║██╔██╗ ██║██║   ██║   ██║   ██║██║██╔████╔██║
" ██║██║╚██╗██║██║   ██║   ╚██╗ ██╔╝██║██║╚██╔╝██║
" ██║██║ ╚████║██║   ██║██╗ ╚████╔╝ ██║██║ ╚═╝ ██║
" ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝╚═╝  ╚═══╝  ╚═╝╚═╝     ╚═╝
"
"                 presented by
"
"               ╔═╗┌─┐┌─┐┌─┐┬┌┐┌
"               ║  ├─┤└─┐└─┐││││
"               ╚═╝┴ ┴└─┘└─┘┴┘└┘

runtime init/main/main.init.vim
runtime init/main/nnormap.init.vim
runtime init/main/othermap.init.vim
runtime init/plugin/plugin_install.init.vim
runtime init/plugin/plugin_settings.init.vim
runtime init/color/color.init.vim
if filereadable('init/secret/secret.vim')
    runtime init/secret/secret.vim
endif
