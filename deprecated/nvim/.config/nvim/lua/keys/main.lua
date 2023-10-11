require('keys/alias')

vim.g.mapleader = " "

-- Copy to clipboard
vm('<leader>y', '"+y')
nm('<leader>Y', '"+yg_')
nm('<leader>y', '"+y')

-- Past from clipboard
nm('<leader>p', '"+p')
nm('<leader>P', '"+P')
vm('<leader>p', '"+p')
vm('<leader>P', '"+P')

-- Use jk | kj instead ESC
im('jk', '<Esc>')
im('kj', '<Esc>')

-- Better tabbing
vm('<', '<gv')
vm('>', '>gv')
