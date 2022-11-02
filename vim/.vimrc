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

syntax on
set mouse-=a

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


" CONFIGURE lightline.vim

set noshowmode
set laststatus=2

let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified', 'cocstatus' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'gitbranch#name',
      \   'cocstatus': 'coc#status'
      \ },
      \ }

" autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()
" END CONFIGURE lightline.vim


" CONFIGURE NERDTree

" Exit Vim if NERDTree is the only window left.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 &&
    \ exists('b:NERDTree') && b:NERDTree.isTabTree() |
    \ quit | endif

" END CONFIGURE NERDTree


" CONFIGURE vim-plug

call plug#begin('~/.vim/plugged')

" Initialize plugin system
call plug#end()

" END CONFIGURE vim-plug
