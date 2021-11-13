scriptencoding utf-8

" update plugins ->
" :PlugInstall
" :UpdateRemotePlugins

call plug#begin()
Plug 'kana/vim-submode'                 " resize split windows

" Spotify integration
Plug 'HendrikPetertje/vimify'

" ---------------------------------------
" Indent
" ---------------------------------------

" " indent guides {{{
" Plug 'Yggdroot/indentLine'
" let g:indentLine_enabled = 1 " disable by default
" let g:indentLine_char = '⎸'
" "}}}

" indent-guides {{{
Plug 'nathanaelkane/vim-indent-guides'
    let g:indent_guides_enable_on_vim_startup=1 " enable indent-guides
    let g:indent_guides_start_level=1
    hi IndentGuidesOdd  ctermbg=239
    hi IndentGuidesEven ctermbg=242
    "let g:indent_guides_auto_colors=0 " enable auto colors
    let g:indent_guides_guide_size=1 " width of identifier
    let g:indent_guides_exclude_filetypes = ['help', 'nerdtree']
    autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd   ctermbg=237
    autocmd VimEnter,Colorscheme * :hi IndentGuidesEven  ctermbg=237

" }}}

": colorlise status line {{{
": SpaceLine {{{
    Plug 'glepnir/spaceline.vim'
    let g:spaceline_colorscheme = 'space'
    let g:spaceline_seperate_style = 'curve'

    " Goyo
    " ----
    " s:goyo_enter() "{{{
    " Disable visual candy in Goyo mode
    function! s:goyo_enter()
        if has('gui_running')
            " Gui fullscreen
            set fullscreen
            set background=light
            set linespace=7
        elseif exists('$TMUX')
            " Hide tmux status
            silent !tmux set status off
        endif
        " Activate Limelight
        let g:loaded_spaceline=0
        Limelight
    endfunction
    " }}}
    " s:goyo_leave() "{{{
    " Enable visuals when leaving Goyo mode
    function! s:goyo_leave()
        if has('gui_running')
            " Gui exit fullscreen
            set nofullscreen
            set background=dark
            set linespace=0
        elseif exists('$TMUX')
            " Show tmux status
            silent !tmux set status on
        endif
        " De-activate Limelight
        let g:loaded_spaceline =1
        Limelight!
    endfunction
    " }}}
    " Goyo Commands {{{
    augroup user_plugin_goyo
        autocmd!
        autocmd! User GoyoEnter
        autocmd! User GoyoLeave
        autocmd  User GoyoEnter nested call <SID>goyo_enter()
        autocmd  User GoyoLeave nested call <SID>goyo_leave()
    augroup END
    " }}}
": }}}

": LightLine {{{
" Plug 'itchyny/lightline.vim'
" let g:lightline = {
"      \ 'colorscheme': 'onedark',
"      \ }
" }}}

": NeoLine
" Plug 'Cassin01/neoline.vim'

": AirLine {{{
" Plug 'vim-airline/vim-airline'
" Plug 'vim-airline/vim-airline-themes'
" Plug 'enricobacis/vim-airline-clock'    " vim-airline clock extension
" set laststatus=2
" let g:airline_powerline_fonts = 1
" let g:airline#extensions#tabline#enabled = 1
" let g:airline#extensions#tabline#buffer_idx_mode = 1
" let g:airline#extensions#whitespace#mixed_indent_algo = 1
" "let g:airline_theme = 'tomorrow'
" if !exists('g:airline_symbols')
"     let g:airline_symbols = {}
" endif
" " unicode symbols
" let g:airline_left_sep = '»'
" let g:airline_left_sep = '▶'
" let g:airline_right_sep = '«'
" let g:airline_right_sep = '◀'
" let g:airline_symbols.crypt = '🔒'
" let g:airline_symbols.linenr = '☰'
" let g:airline_symbols.linenr = '␊'
" let g:airline_symbols.linenr = '␤'
" let g:airline_symbols.linenr = '¶'
" let g:airline_symbols.maxlinenr = ''
" let g:airline_symbols.maxlinenr = '㏑'
" let g:airline_symbols.branch = '⎇'
" let g:airline_symbols.paste = 'ρ'
" let g:airline_symbols.paste = 'Þ'
" let g:airline_symbols.paste = '∥'
" let g:airline_symbols.spell = 'Ꞩ'
" let g:airline_symbols.notexists = '∄'
" let g:airline_symbols.whitespace = 'Ξ'

" " powerline symbols
" let g:airline_left_sep = ''
" let g:airline_left_alt_sep = ''
" let g:airline_right_sep = ''
" let g:airline_right_alt_sep = ''
" let g:airline_symbols.branch = ''
" let g:airline_symbols.readonly = ''
" let g:airline_symbols.linenr = '☰'
" let g:airline_symbols.maxlinenr = ''
": }}}
": }}}

" ---------------------------------------
" Syntax
" ---------------------------------------

" syntastic {{{
Plug 'vim-syntastic/syntastic'
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_mode_map = {
      \ 'mode': 'passive',
      \ 'active_filetypes': ['c','cpp']
      \}
let g:syntastic_cpp_compiler = 'clang++'
let g:syntastic_cpp_compiler_options = ' -std=c++11 -stdlib=libc++'
" }}}

" pathogen for syntastic
Plug 'tpope/vim-pathogen'

" auto format {{{
Plug 'Chiel92/vim-autoformat'
let g:formatter_yapf_style = 'pep8'
" }}}

" nvim-treesitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " We recommend updating the parsers on update


" ---------------------------------------
" Language
" ---------------------------------------

" haskell {{{
Plug 'eagletmt/neco-ghc'                " completion
Plug 'neovimhaskell/haskell-vim'        " syntax
    " {{{
    Plug 'dag/vim2hs'                       " syntax, indent
    " disable concealing of "enumerations": commatized lists like
    " deriving clauses and LANGUAGE pragmas,
    " otherwise collapsed into a single ellipsis
    let g:haskell_conceal_enumerations = 0
    let g:haskell_conceal              = 0
    " }}}
" }}}

" python3
Plug 'davidhalter/jedi-vim'             " completion
Plug 'numirias/semshi', {'do': ':UpdateRemotePlugins'} " Semantic Highlighting for Python in Neovim

" Go
" vim-go {{{
" Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' } 
" let g:go_fmt_options = "-tabwidth=4"
" autocmd FileType go nmap <leader>b  <Plug>(go-build)
" autocmd FileType go nmap <leader>r  <Plug>(go-run)
" }}}

" c++ {{{
Plug 'octol/vim-cpp-enhanced-highlight' " syntax highlight
" completion {{{
Plug 'justmao945/vim-clang'
let g:clang_c_options = '-std=gnu11'
let g:clang_cpp_options = '-std=c++11 -stdlib=libc++' " c++11 用
let g:clang_auto = 0 " disable auto completion for vim-clang
" }}}
Plug 'rhysd/vim-clang-format'
let g:clang_format#style_options = {
            \ "AccessModifierOffset" : -4,
            \ "AllowShortIfStatementsOnASingleLine" : "true",
            \ "AlwaysBreakTemplateDeclarations" : "true",
            \ "Standard" : "C++11",
            \ "BreakBeforeBraces" : "Stroustrup"}
" }}}

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

" processing-java
Plug 'sophacles/vim-processing'

" swift
Plug 'keith/swift.vim'
Plug 'jpsim/SourceKitten'

" tex {{{
Plug 'lervag/vimtex'
let g:vimtex_compiler_latexmk_engines = {'_': '-pdfdvi'}
let g:vimtex_view_method= 'skim'
"let g:vimtex_quickfix_latexlog = {'default': 0}
let g:vimtex_quickfix_igonre_filters = {'default': 0}
if empty(v:servername) && exists('*remote_startserver')
    call remote_startserver('VIM')
endif
" }}}

" toml
Plug 'cespare/vim-toml'

" json {{{
Plug 'elzr/vim-json'
let g:vim_json_syntax_conceal=0
" }}}

"markdown {{{
    Plug 'godlygeek/tabular'
    Plug 'plasticboy/vim-markdown'

    " Preview系 {{{
        " 一軍 {{{
        " Plug 'suan/vim-instant-markdown', {'for': 'markdown'}
        " let g:instant_markdown_autostart = 0
        " }}}

        " 二軍 {{{
        Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app & yarn install'  }

        " set to 1, the nvim will auto close current preview window when change
        " from markdown buffer to another buffer
        " default: 1
        let g:mkdp_auto_close = 0

        let g:mkdp_preview_options = {
                    \ 'katex': {},
                    \ 'disable_sync_scroll': 0,
                    \ }

        " normal/insert
        nmap ,p <Plug>MarkdownPreview
        " }}}
    " }}}

    " Automatic table creator & formatte
    Plug 'dhruvasagar/vim-table-mode' " {{{
    function! s:isAtStartOfLine(mapping)
        let text_before_cursor = getline('.')[0 : col('.')-1]
        let mapping_pattern = '\V' . escape(a:mapping, '\')
        let comment_pattern = '\V' . escape(substitute(&l:commentstring, '%s.*$', '', ''), '\')
        return (text_before_cursor =~? '^' . ('\v(' . comment_pattern . '\v)?') . '\s*\v' . mapping_pattern . '\v$')
    endfunction

    inoreabbrev <expr> <bar><bar>
                \ <SID>isAtStartOfLine('\|\|') ?
                \ '<c-o>:TableModeEnable<cr><bar><space><bar><left><left>' : '<bar><bar>'
    inoreabbrev <expr> __
                \ <SID>isAtStartOfLine('__') ?
                \ '<c-o>:silent! TableModeDisable<cr>' : '__'
    " }}}
" }}}

" html
Plug 'mattn/emmet-vim'

" A solid language pack {{{
Plug 'sheerun/vim-polyglot'

let g:polyglot_disabled = ['markdown']
" }}}

" :Unite colorscheme -auto-preview
Plug 'Shougo/unite.vim'
Plug 'ujihisa/unite-colorscheme'

" colorschemes {{{
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
    Plug 'kristijanhusak/vim-hybrid-material' " hybrid_material
    Plug 'drewtempelmeyer/palenight.vim'      " palenight
    Plug 'haishanh/night-owl.vim'             " night owl
    Plug 'arcticicestudio/nord-vim'           " nord
    Plug 'cocopon/iceberg.vim'                " iceberg
    Plug 'hzchirs/vim-material'               "vim-material"
    Plug 'kyoz/purify', {'rtp': 'vim'}        "purify"
    Plug 'relastle/bluewery.vim'              "bluewery"
    Plug 'mhartington/oceanic-next'           "OceanicNext
    Plug 'nightsense/snow'                    "snow
    Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
    Plug 'Mangeshrex/uwu.vim'                 "uwu"
" }}}

" ---------------------------------------------------------------
"  Files
" ---------------------------------------------------------------

" Nerdtree {{{
Plug 'scrooloose/nerdtree'
" Change current directory.
nnoremap <silent> <Space>cd :<C-u>CD<CR>
" {{{

" fzf completion
Plug '/usr/local/opt/fzf'
nnoremap mff :<c-u>FZF<space>
nnoremap mfr :<c-u>FZF<space>~/<cr>
nnoremap mfc :<c-u>FZF<space>./<cr>

" ranger file manager {{{
Plug 'francoiscabrol/ranger.vim'
Plug 'rbgrouleff/bclose.vim'
" }}}

" snippets && vim-lsp
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
"Plug 'prabirshrestha/async.vim'           "vim-lsp
"Plug 'prabirshrestha/vim-lsp'             "vim-lsp
"" After vim-lsp, etc
"Plug 'ryanolsonx/vim-lsp-python'          "python
"
""Plug 'autozimu/LanguageClient-neovim'     " lsp support
"Plug 'autozimu/LanguageClient-neovim', {
"    \ 'branch': 'next',
"    \ 'do': './install.sh'
"    \ }

" multiple cursors
Plug 'terryma/vim-multiple-cursors'

" git " {{{
Plug 'tpope/vim-fugitive'
"set statusline+=%{FugitiveStatusline()}
nnoremap mgg :<c-u>Git<CR>
nnoremap mgc :<c-u>Git commit<CR>
nnoremap mgp :<c-u>Git push<CR>
" }}}

" shows a git diff in the gutter (sign column) and stages/undoes (partial) hunks.
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-rhubarb' " enable :Gbrowse

" ---------------------------------------
" Others
" ---------------------------------------

" quoting/parenthesizing made simple
Plug 'tpope/vim-surround'

" calender {{{
Plug 'itchyny/calendar.vim'
let g:calendar_google_calendar = 1
let g:calendar_google_task = 1
" }}}

" shougo completion {{{
" if has('nvim')
"   Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
" else
"   Plug 'Shougo/deoplete.nvim'
"   Plug 'roxma/nvim-yarp'
"   Plug 'roxma/vim-hug-neovim-rpc'
" endif
" let g:deoplete#enable_at_startup = 1 " Use deoplate

Plug 'Shougo/neosnippet.vim'
Plug 'Shougo/neosnippet-snippets'
" }}}

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
nnoremap <silent> <leader>z :Goyo<cr>
Plug 'amix/vim-zenroom2' "A Vim extension that emulates iA Writer environment when editing Markdown, reStructuredText or text files

" vim motion on speed! {{{
Plug 'easymotion/vim-easymotion'
" }}}

" Jump to any visible line in the buffer by using letters instead of numbers. {{{
Plug 'skamsie/vim-lineletters'
map <silent>sa <Plug>LineLetters
" }}}

" Vim plugin that displays tags in a window, {{{
Plug 'majutsushi/tagbar'
nmap <space>t :TagbarToggle<CR>
g:tagbar_ctags_bin = /usr/local/opt/universal-ctags
" }}}

" Comment stuff out.
Plug 'tpope/vim-commentary'

" 揃える {{{
Plug 'junegunn/vim-easy-align'
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)
" }}}

" icon {{{
Plug 'ryanoasis/vim-devicons'
set guifont=DroidSansMono_Nerd_Font:h11
" }}}

" Visual mode 範囲拡大 {{{
Plug 'terryma/vim-expand-region'
vmap v <Plug>(expand_region_expand)
vmap <C-v> <Plug>(expand_region_shrink)
" }}}

" rainbow parentheses
Plug 'luochen1990/rainbow'
let g:rainbow_active = 0

" quickrun
Plug 'thinca/vim-quickrun'

" f,F,t,T による前方検索
" nnoremap `f,F,t,T` extention
Plug 'rhysd/clever-f.vim'

" Move visually selected text
Plug 'Jorengarenar/vim-MvVis'

" WhichKey :displays available keybindings in popup. {{{
Plug 'liuchengxu/vim-which-key', { 'on': ['WhichKey', 'WhichKey!'] }
nnoremap <silent> <leader>      :<c-u>WhichKey '<leader>'<CR>
nnoremap <silent> <localleader> :<c-u>WhichKey  '<localleader>'<CR>
nnoremap <silent> m :<c-u>WhichKey 'm'<CR>
nnoremap <silent> s :<c-u>WhichKey 's'<CR>
nnoremap <silent> , :<c-u>WhichKey ','<CR>
nnoremap <silent> ; :<c-u>WhichKey ';'<CR>
nnoremap <silent> <space> :<c-u>WhichKey '<space>'<CR>
" }}}

"  complementary pairs of mappings. -> ] or [
Plug 'tpope/vim-unimpaired'

" Automatically save
Plug  'vim-scripts/vim-auto-save' " {{{
let g:auto_save_events = ["InsertLeave", "TextChanged"]
let g:auto_save = 0
" }}}

" notes {{{
Plug 'xolox/vim-notes'
Plug 'xolox/vim-misc'
" }}}

" Open URL with your browser {{{
Plug 'tyru/open-browser.vim'
nmap <leader>b <Plug>(openbrowser-smart-search)
vmap <leader>b <Plug>(openbrowser-smart-search)
" }}}

" conceal
Plug 'Cassin01/vim-conceal'

call plug#end()

" ---------------------------------------
" Lua config
" ---------------------------------------

lua <<EOF
-- nvim-treesitter/nvim-treesitter
require'nvim-treesitter.configs'.setup {
  ensure_installed = "maintained", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  highlight = {
    enable = true,              -- false will disable the whole extension
    disable = { "vue", "ruby" },  -- list of language that will be disabled
  },
}
EOF
