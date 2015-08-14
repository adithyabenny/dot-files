" Settings
set foldenable              " enable folding
set foldlevelstart=10       " open most folds by default
set foldnestmax=10          " 10 nested fold max
set foldmethod=indent       " fold based on indent level
let mapleader=","           " leader is comma


" Indentation
filetype plugin indent on   " enable the default indent plugin
set expandtab               " tabs are spaces
set shiftwidth=2            " number of spaces to move when using << or >>
set softtabstop=2           " number of spaces in tab when editing
set tabstop=2               " number of visual spaces per TAB
set pastetoggle=<F2>        " toggle option to paste text unmodified
set autoindent              " newline has the same indentation as the present line


" Highlight
" turn off search highlight
  nnoremap <leader><space> :nohlsearch<CR>
syntax on                   " enable syntax processing
set hlsearch                " highlight matches
set incsearch               " search as characters are entered
set ignorecase              " search is not case sensitive
set showmatch               " highlight matching [{()}]
set smartcase               " search is case sensitive if it has both upper and lower case


" Navigation
" move vertically down by visual line
  nnoremap j gj
  nnoremap k gk
set cursorline              " highlight current line
set number                  " show line numbers
set scrolloff=10            " number of lines to be shown above and below the cursor
set showcmd                 " show information about the current command going on
set wildmenu                " visual autocomplete for command menu


" Shortcuts
" source ~/.vimrc
  nnoremap <leader>sv :source $MYVIMRC<CR>
" write, save, quit
  map <Esc>s :w<CR>
  map <Esc>S :w !sudo tee % > /dev/null<CR>
  map <Esc>w :wq!<CR>
  map <Esc>q :q!<CR>


" Appearance
colorscheme elflord         " set a custom color scheme
" change the selected menu entry's background color to make it more visible
  highlight PmenuSel ctermbg=4
" highlight trailing whitespaces
  highlight ExtraWhitespace ctermbg=red guibg=red
  match ExtraWhitespace /\s\+$/
  autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
  autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
  autocmd InsertLeave * match ExtraWhitespace /\s\+$/
  autocmd BufWinLeave * call clearmatches()
