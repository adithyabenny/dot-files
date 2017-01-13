" Settings
let mapleader=","                                                    " set the command prefix from the default '\' to ','
set lazyredraw                                                       " don't redraw in between macros
set backspace=indent,eol,start                                       " allow backspace to erase previously entered characters
set wildmenu                                                         " visual autocomplete for command menu


" Folding
set foldenable                                                       " enable folding
set foldlevelstart=10                                                " open most folds by default
set foldnestmax=10                                                   " 10 nested fold max
set foldmethod=indent                                                " fold based on indent level
nnoremap <space> za                                                  " space opens/closes folds


" Indentation
filetype plugin indent on                                            " enable the default indent plugin
set expandtab                                                        " tabs are spaces
set shiftwidth=2                                                     " number of spaces to move when using << or >>
set softtabstop=2                                                    " number of spaces in tab when editing
set tabstop=2                                                        " number of visual spaces per tab
set autoindent                                                       " new line has the same indentation as the present line


" Search
" <comma>,<space> will turn off search highlight
nnoremap <leader><space> :nohlsearch<CR>
syntax on                                                            " enable syntax processing
set hlsearch                                                         " highlight matches
set incsearch                                                        " search as characters are entered
set ignorecase                                                       " search is not case sensitive
set showmatch                                                        " highlight matching parantheses
set smartcase                                                        " search is case sensitive if it has both upper and lower case


" Navigation
" move vertically down by visual line using j/k
nnoremap j gj
nnoremap k gk
set number                                                           " show line numbers on the left pane
set ruler                                                            " show line and column number in the status bar
set scrolloff=10                                                     " number of lines to be shown above and below the cursor
set showcmd                                                          " show information about the current command going on


" Shortcuts
" <comma>,sv will source ~/.vimrc
nnoremap <leader>sv :source $MYVIMRC<CR>
" <escape>,s will save the file
map <Esc>s :w<CR>
" <escape>,S will save the file with elevated privileges
map <Esc>S :w !sudo tee % > /dev/null<CR>
" <escape>,w will save the file and then quit
map <Esc>w :wq!<CR>
" <escape>,q will quit the file without saving
map <Esc>q :q!<CR>
" F2 will toggle the option to paste text unmodified
set pastetoggle=<F2>
" F3 will remove all trailing whitespaces
nnoremap <silent> <F3> :let _s=@/ <Bar> :%s/\s\+$//e <Bar> :let @/=_s <Bar> :nohl <Bar> :unlet _s <CR>
" F5 will toggle spell check
map <F5> :setlocal spell!<CR>


" Plugins
" execute the below command for setting up vim-plug, a minimalistic Vim plugin manager
" curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
" then execute :PlugInstall inside Vim to set up all these plugins
call plug#begin('~/.vim/plugged')
Plug 'scrooloose/nerdtree', {'on': 'NERDTreeToggle'}                 " tree explorer
Plug 'scrooloose/syntastic'                                          " syntax checker
Plug 'tpope/vim-surround'                                            " quoting/parenthesizing made simple
Plug 'scrooloose/nerdcommenter'                                      " powerful comment functions
Plug 'airblade/vim-gitgutter'                                        " show git diff in the sign column
Plug 'altercation/vim-colors-solarized'                              " set color scheme to solarized
call plug#end()
" Syntastic plugin settings
set statusline+=%#WarningMsg#                                        " enable highlight group 'WarningMsg'
set statusline+=%{SyntasticStatuslineFlag()}                         " enable error flagging on the statusline
set statusline+=%*                                                   " restore normal highlight
let g:syntastic_check_on_open = 1                                    " run syntax checks when buffers are loaded
let g:syntastic_check_on_wq = 0                                      " don't syntax check before write quit
" Solarized plugin settings
set background=dark                                                  " select Solarized dark theme instead of light
let g:solarized_termtrans = 1                                        " accout for your terminal emulator being transparent
let g:solarized_termcolors = 256                                     " use the 256 color scheme
colorscheme solarized                                                " unable the Solarized color scheme


" Appearance
" change the selected menu entry's background color to make it more visible
highlight PmenuSel ctermbg=4
" highlight trailing whitespaces
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()
