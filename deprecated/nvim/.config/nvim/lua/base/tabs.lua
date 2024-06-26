local opt = vim.opt

opt.tabstop=2       -- How many columns of whitespace a \t is worth.
opt.shiftwidth=2    -- Is how many columns of whitespace a 'level of indentation' is worth.
opt.softtabstop=2   -- How many columns of whitespace a tab keypress or a backspace keypress is worth.
opt.expandtab=true  -- use spaces instead of tabs (\t).
opt.scrolloff=8     -- set number of screen lines to keep above/below the cursor
opt.showtabline=2   -- Always show tabs (default 1)

-- Indent: https://neovim.io/doc/user/indent.html
opt.smartindent=true                    -- Makes indenting smart
opt.autoindent=true                     -- uses the indent from the previous line

