unlet! skip_defaults_vim
source $VIMRUNTIME/defaults.vim

" Only do this part when compiled with support for autocommands.
if has("autocmd")
    " Use filetype detection and file-based automatic indenting.
    filetype plugin indent on

    " Use actual tab chars in Makefiles.
    autocmd FileType make set tabstop=8 shiftwidth=8 softtabstop=0 noexpandtab
endif

" For everything else, use a tab width of 2 space chars.
set tabstop=2       " How many columns of whitespace a \t is worth.
set shiftwidth=2    " Is how many columns of whitespace a 'level of indentation' is worth.
set softtabstop=2   " How many columns of whitespace a tab keypress or a backspace keypress is worth.
set expandtab       " Means that you never wanna see a \t again in your file.
set incsearch       " While searching though a file incrementally highlight matching characters as you type.
set ignorecase      " Ignore capital letters during search.
" Override the ignorecase option if searching for capital letters.
set smartcase       " This will allow you to search specifically for capital letters.
set showcmd         " Show partial command you type in the last line of the screen.
set showmode        " Show the mode you are on the last line.
set showmatch       " Show matching words during a search.
set hlsearch        " Use highlighting when doing a search.
set history=1000    " Set the commands to save in history default number is 20.

syntax on           " Turn syntax highlighting on.
set number          " Add numbers to each line on the left-hand side.
set cursorline      " Highlight cursor line underneath the cursor horizontally.
set cursorcolumn    " Highlight cursor line underneath the cursor vertically.
set mouse-=a

set wildmenu              " Enable auto completion menu after pressing TAB.
set wildmode=list:longest " Make wildmenu behave like similar to Bash completion.
" There are certain files that we would never want to edit with Vim.
" Wildmenu will ignore files with these extensions.
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx

" change colorscheme
colorscheme wombat256grf  


" CONFIGURE KEYBINDINGS

" Strip all trailing whitespace.
nnoremap <F5> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar><CR>

" Search for visually selected text
vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>

" Tabs
nnoremap <C-Left> :tabprevious<CR>
nnoremap <C-Right> :tabnext<CR>

" Multiple paste with contents of clipboard.
" You still can use P to get the old behaviour.
xnoremap p pgvy

" END CONFIGURE KEYBINDINGS


" CONFIGURE vim-plug
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

call plug#end() " Initialize plugin system
" END CONFIGURE vim-plug
