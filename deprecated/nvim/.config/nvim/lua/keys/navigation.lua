require('keys/alias')

vim.g.mapleader = " "

-- Better window navigation
nm('<C-h>','<C-w>h')
nm('<C-j>','<C-w>j')
nm('<C-k>','<C-w>k')
nm('<C-l>','<C-w>l')

-- Next/Previous line with out comments
nm('<Leader>o','o<Esc>^Da')
nm('<Leader>O','O<Esc>^Da')
