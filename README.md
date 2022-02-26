# My neovim configuration

# Features
- **[Fennel based]** enjoying lisp's powerful expression

- **[Powerful editing]** using more than 80 plugins.

- **[Simple key-binding]** systematized prefix.

## Installation
1. ``pip3 install pynvim``
2. Check ``let g:python3_host_prog``'s (at ``fnl/core/options.fnl``) path is collect.
3. Install [vim-plug](https://github.com/junegunn/vim-plug/releases) and [packer](https://github.com/wbthomason/packer.nvim) beforehand.
4. Set this code at ``~/.config/nvim/``.
5. Place [fennel-util-functions](https://github.com/Cassin01?tab=repositories)'s `src` on $HOME/.config/nvim/fnl/util
6. ``pip3 install neovim-remote`` for ``mhinz/neovim-remote``.
7. ``:PlugInstall`` for installing plugins.

### NerdFonts

Both ``Devicon-plugin`` and ``Airline-plugin`` require [nerd-fonts](https://github.com/ryanoasis/nerd-fonts).
