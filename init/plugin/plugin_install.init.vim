scriptencoding utf-8

" update plugins ->
" :PlugInstall
" :UpdateRemotePlugins

call plug#begin()
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'kana/vim-submode'                 " resize split windows

" Spotify integration
Plug 'HendrikPetertje/vimify'

" indent guides
Plug 'Yggdroot/indentLine'

" colorlise status line
" Plug 'itchyny/lightline.vim'
" Plug 'Cassin01/neoline.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'enricobacis/vim-airline-clock'    " vim-airline clock extension

" syntastic
Plug 'vim-syntastic/syntastic'

" pathogen for syntastic
Plug 'tpope/vim-pathogen'

" auto format
Plug 'Chiel92/vim-autoformat'

" haskell
Plug 'eagletmt/neco-ghc'                " completion
Plug 'neovimhaskell/haskell-vim'        " syntax
Plug 'dag/vim2hs'                       " syntax, indent

" python3
Plug 'davidhalter/jedi-vim'             " completion
Plug 'numirias/semshi', {'do': ':UpdateRemotePlugins'} " Semantic Highlighting for Python in Neovim

" Go
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

" c++
Plug 'octol/vim-cpp-enhanced-highlight' " syntax highlight
Plug 'justmao945/vim-clang'             " completion

" Ruby
Plug 'vim-ruby/vim-ruby'

" Rust
Plug 'rust-lang/rust.vim'              " completion
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Dart
Plug 'dart-lang/dart-vim-plugin'

" JavaScript
Plug 'othree/yajs.vim' "syntax highlight
Plug 'ternjs/tern_for_vim' "auto completion
Plug 'pangloss/vim-javascript' "indentation and syntax support

" toml
Plug 'cespare/vim-toml'

" json
Plug 'elzr/vim-json'

"markdown
"Plug 'godlygeek/tabular'
"Plug 'plasticboy/vim-markdown'
Plug 'suan/vim-instant-markdown', {'for': 'markdown'}

" html
Plug 'mattn/emmet-vim'

" :Unite colorscheme -auto-preview
Plug 'Shougo/unite.vim'
Plug 'ujihisa/unite-colorscheme'

" colorschemes
Plug 'altercation/vim-colors-solarized'   " solarized
Plug 'croaker/mustang-vim'                " mustang
Plug 'jeffreyiacono/vim-colors-wombat'    " wombat
Plug 'nanotech/jellybeans.vim'            " jellybeans
Plug 'vim-scripts/Lucius'                 " lucius
Plug 'vim-scripts/Zenburn'                " zenburn
Plug 'mrkn/mrkn256.vim'                   " mrkn256
Plug 'jpo/vim-railscasts-theme'           " railscasts
Plug 'therubymug/vim-pyte'                " pyte
Plug 'tomasr/molokai'                     " molokai
Plug 'chriskempson/vim-tomorrow-theme'    " tomorrow night
Plug 'vim-scripts/twilight'               " twilight
Plug 'w0ng/vim-hybrid'                    " hybrid
Plug 'freeo/vim-kalisi'                   " kalisi
Plug 'morhetz/gruvbox'                    " gruvbox
Plug 'toupeira/vim-desertink'             " desertink
Plug 'sjl/badwolf'                        " badwolf
Plug 'itchyny/landscape.vim'              " landscape
Plug 'joshdick/onedark.vim'               " onedark in atom
Plug 'gosukiwi/vim-atom-dark'             " atom-dark
Plug 'liuchengxu/space-vim-dark'          " space-vim-dark -> recommended 'hi Comment cterm=italic'
Plug 'kristijanhusak/vim-hybrid-material' "hybrid_material
Plug 'drewtempelmeyer/palenight.vim'      " palenight
Plug 'haishanh/night-owl.vim'             " night owl
Plug 'arcticicestudio/nord-vim'           " nord
Plug 'cocopon/iceberg.vim'                " iceberg

" others
Plug 'scrooloose/nerdtree'

" fzf completion
Plug '/usr/local/opt/fzf'

" snippets && vim-lsp
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'prabirshrestha/async.vim'           "vim-lsp
Plug 'prabirshrestha/vim-lsp'             "vim-lsp
" After vim-lsp, etc
Plug 'ryanolsonx/vim-lsp-python'          "python

Plug 'autozimu/LanguageClient-neovim'     " lsp support

" multiple cursors
Plug 'terryma/vim-multiple-cursors'

" git
Plug 'tpope/vim-fugitive'

" shows a git diff in the gutter (sign column) and stages/undoes (partial) hunks.
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-rhubarb' " enable :Gbrowse

" quoting/parenthesizing made simple
Plug 'tpope/vim-surround'

" calender
Plug 'itchyny/calendar.vim'

" shougo completion start
if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif
let g:deoplete#enable_at_startup = 1 " Use deoplate

Plug 'Shougo/neosnippet.vim'
Plug 'Shougo/neosnippet-snippets'
" shougo completion end

" :terminal親のvimを操作できるようにする
Plug 'mhinz/neovim-remote'

" game
Plug 'mattn/flappyvird-vim'

" auto-collect
Plug 'sedm0784/vim-you-autocorrect'

" org mode
Plug 'jceb/vim-orgmode'

" Distraction-free writing in Vim
Plug 'junegunn/goyo.vim'
Plug 'amix/vim-zenroom2' "A Vim extension that emulates iA Writer environment when editing Markdown, reStructuredText or text files

" vim motion on speed!
Plug 'easymotion/vim-easymotion'

" Vim plugin that displays tags in a window,
Plug 'majutsushi/tagbar'

" Comment stuff out.
Plug 'tpope/vim-commentary'

"A solid language pack for Vim.
Plug 'sheerun/vim-polyglot'

" 揃える
Plug 'junegunn/vim-easy-align'


call plug#end()
