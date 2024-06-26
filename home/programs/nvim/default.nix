{ pkgs, vars, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraLuaConfig = /* lua */ ''
      -- Алиас для быстрого доступа к методу установки горячих клавиш
      local map = vim.api.nvim_set_keymap

      --[[
      Метод для установки горячих клавиш (normal)
      key - {string} Строка с горячей клавишей
      command - {string} Команда
      ]]--
      function nm(key, command)
        map('n', key, command, {noremap = true})
      end

      --[[
      Метод для установки горячих клавиш (input)
      key - {string} Строка с горячей клавишей
      command - {string} Команда
      ]]--
      function im(key, command)
        map('i', key, command, {noremap = true})
      end

      --[[
      Метод для установки горячих клавиш (visual)
      key - {string} Строка с горячей клавишей
      command - {string} Команда
      ]]--
      function vm(key, command)
        map('v', key, command, {noremap = true})
      end

      --[[
      Метод для установки горячих клавиш (terminal)
      key - {string} Строка с горячей клавишей
      command - {string} Команда
      ]]--
      function tm(key, command)
        map('t', key, command, {noremap = true})
      end

      vim.o.termguicolors=true
      vim.o.mouse=a                 -- Enable your mouse

      vim.o.tabstop       = 2 -- How many columns of whitespace a \t is worth.
      vim.o.shiftwidth    = 2 -- Is how many columns of whitespace a 'level of indentation' is worth.
      vim.o.softtabstop   = 2 -- How many columns of whitespace a tab keypress or a backspace keypress is worth.
      vim.o.expandtab     = true -- use spaces instead of tabs (\t).
      vim.o.scrolloff     = 8 -- set number of screen lines to keep above/below the cursor
      vim.o.showtabline   = 2 -- Always show tabs (default 1)

      -- Indent: https://neovim.io/doc/user/indent.html
      vim.o.smartindent=true        -- Makes indenting smart
      vim.o.autoindent=true         -- uses the indent from the previous line

      -- Number of lines: https://neovim.io/doc/user/vim.oions.html#'number'
      vim.o.number=true             -- Line numbers
      vim.o.relativenumber=true			-- Set displayed number to be relative to the cursor

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
    '';
  };
}
