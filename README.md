# My neovim configuration

# Features

- **[Powerful editing]** using more than 80 plugins.

- **[Simple key-binding]** systematized prefix.

## Installation
0. `$ make`
1. ``pip3 install pynvim``
2. check ``let g:python3_host_prog``'s (at ``init/main/main.init.vim``) path is collect
3. Install [vim-plug](https://github.com/junegunn/vim-plug/releases) beforehand.
4. Set this code at ``~/.config/nvim/``.
5. ``pip3 install neovim-remote`` for ``mhinz/neovim-remote``
6. ``:PlugInstall`` for installing plugins

## Dependencies

### NerdFonts

Both ``Devicon-plugin`` and ``Airline-plugin`` require [nerd-fonts](https://github.com/ryanoasis/nerd-fonts).

### Mac

If you don't use this configuration on mac, You should remove this code from ``init/main/nnoremap.init.vim``.

```nnoremap.init.vim
" mac only!!!!!!!!!!!!!! {{{
    nnoremap ,? :!open dict://<cword><CR>
" }}}
