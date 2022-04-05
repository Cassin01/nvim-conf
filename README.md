# neovim configuration

Powered by [hotpot.nvim](https://github.com/rktjmp/hotpot.nvim).

## Features

- **[Fennel based]** enjoying lisp's powerful expression

- **[Muscled editing]** using more than 100 plugins.

- **[Simple key-binding]** systematized prefix.

### Requires

1. ``pip3 install pynvim``
2. [packer](https://github.com/wbthomason/packer.nvim)

---

## The following may be usefull infomation for one who start writing nvim setup by fennel.

### Reference

[reference](https://fennel-lang.org/reference)

### plugins

#### syntax

- [fennel.vim](https://github.com/bakpakin/fennel.vim')

#### native fennel support

- [fennel-nvim](https://github.com/jaawerth/fennel-nvim')

#### transpile and path setting

- [hotpot](https://github.com/rktjmp/hotpot.nvim)

- [aniseed](https://github.com/Olical/aniseed)

#### libralies

- [zest](https://github.com/tsbohc/zest.nvim)
- [fulib.nvim](https://github.com/6cdh/fulib.nvim)

### dotfiles

#### using aniseed
- [alexaandru](https://github.com/alexaandru/nvim-config/tree/master/fnl)
    - white and brack icon

- [camspiers/dotfiles](https://github.com/camspiers/dotfiles/blob/master/files/.config/nvim/fnl/options.fnl)
    - using aniseed, neat

- [nyoom.nvim](https://www.libhunt.com/topic/neovim-dotfiles)
    - full fennel

- [dm9pZCAq](https://notabug.org/dm9pZCAq/dotfiles/src/master/.config/nvim)
    - all writen in fennel and all file will be compiled.

- [datwaft](https://github.com/datwaft/nvim.conf/blob/main/fnl/conf/settings.fnl)
    - producer of hotpot

- [tsbohc](https://github.com/tsbohc/.garden/tree/master/etc/nvim_old/config/fnl/core)
    - using zest

#### using hotpot

 - [6cdh](https://github.com/6cdh/dotfiles/tree/main/editor/nvim)
     - producer of fulib.nvim

### plugin for s-expressions

- [paredit](https://github.com/vim-scripts/paredit.vim)
    - ⭐ 168 (Im not using)

- [vim-sexp](https://github.com/guns/vim-sexp)
    - ⭐ 541

```
(a (b ...)) -> (a) (b ...)
(a) (b) -> (a b)
(a (b)) -> (b)
```

- [vim-sexp-mappings-for-regular-people](https://github.com/tpope/vim-sexp-mappings-for-regular-people)
    - ⭐ 368

- [parinfer](https://github.com/bhurlow/vim-parinfer)
    - ⭐ 161 (Im not using)
    - auto right-bracket complication and indentation
