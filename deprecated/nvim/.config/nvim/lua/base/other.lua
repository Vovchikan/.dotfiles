local cmd = vim.cmd             -- execute Vim commands
local exec = vim.api.nvim_exec  -- execute Vimscript
local g = vim.g                 -- global variables
local opt = vim.opt             -- global/buffer/windows-scoped options

-- Number of lines: https://neovim.io/doc/user/options.html#'number'
opt.number=true                         -- Line numbers
opt.relativenumber=true			-- Set displayed number to be relative to the cursor

--opt.iskeyword+=-                      	-- treat dash separated words as a word text object https://neovim.io/doc/user/options.html#'iskeyword'
opt.mouse=a                             -- Enable your mouse

opt.splitbelow=true                     -- Horizontal splits will automatically be below (default off)
opt.splitright=true                     -- Vertical splits will automatically be to the right (default off)
opt.cursorline=true                     -- Enable highlighting of the current line
opt.backup=false                            -- This is recommended by coc
opt.writebackup=false                       -- This is recommended by coc
opt.updatetime=300                      -- Faster completion
opt.timeoutlen=500                      -- By default timeoutlen is 1000 ms
--opt.clipboard='unnamedplus'               -- Copy paste between vim and everything else



--set autochdir                           -- Your working directory will always be the same as your working directory
--opt.formatoptions-=cro                  -- Stop newline continution of comments

-- Visual
opt.pumheight=10                        -- Makes popup menu smaller
opt.cmdheight=2                         -- More space for displaying messages (default 1)
opt.showmode=false                      -- We don't need to see things like -- INSERT -- anymore (default on)
opt.completeopt = 'menuone,noselect'    -- Built-in auto-completion
opt.fixeol = false                      -- Remove extension from file's name
