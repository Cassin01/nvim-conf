# ReiwaVimConfiguration

```vim
██╗███╗   ██╗██╗████████╗██╗   ██╗██╗███╗   ███╗
██║████╗  ██║██║╚══██╔══╝██║   ██║██║████╗ ████║
██║██╔██╗ ██║██║   ██║   ██║   ██║██║██╔████╔██║
██║██║╚██╗██║██║   ██║   ╚██╗ ██╔╝██║██║╚██╔╝██║
██║██║ ╚████║██║   ██║██╗ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝╚═╝  ╚═══╝  ╚═╝╚═╝     ╚═╝

                presented by

              ╔═╗┌─┐┌─┐┌─┐┬┌┐┌
              ║  ├─┤└─┐└─┐││││
              ╚═╝┴ ┴└─┘└─┘┴┘└┘

```

## Installation

0. ``pip3 install pynvim``
1. check ``let g:python3_host_prog``'s (at ``init/main/main.init.vim``) path is collect
2. Install [vim-plug](https://github.com/junegunn/vim-plug/releases) beforehand.
3. Set this code at ``~/.config/nvim/``.
4. ``pip3 install neovim-remote`` for ``mhinz/neovim-remote``
5. ``:PlugInstall`` for installing plugins

## Dependencies

If you don't use this configuration at mac, You should remove this code from ``init/main/nnoremap.init.vim``

```nnoremap.init.vim
" ---------------------------
"  mac only!!!!!!!!!!!!!!!!!!
"  start
" ---------------------------
nnoremap ,? :!open dict://<cword><CR>
" ---------------------------
"  end
"  mac only!!!!!!!!!!!!!!!!!!
" ---------------------------
```
