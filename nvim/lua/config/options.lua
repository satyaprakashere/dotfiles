-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- System-wide shell setting (moved from keymaps.lua)
vim.opt.shell = "fish"

-- Basic settings (moved from config.vim)
vim.opt.number = true -- Show line numbers
vim.opt.relativenumber = true -- Relative line numbers
vim.opt.tabstop = 4 -- Number of spaces per tab
vim.opt.shiftwidth = 4 -- Number of spaces per indentation
vim.opt.expandtab = true -- Convert tabs to spaces
vim.opt.mouse = "a" -- Enable mouse support
vim.opt.termguicolors = true -- True color support
vim.opt.ignorecase = true -- Case insensitive searching
vim.opt.smartcase = true -- ... unless uppercase is used
vim.opt.undofile = true -- Persistent undo
vim.opt.cursorline = true -- Highlight current line

-- Custom options
vim.o.guifont = "Hack Nerd Font Mono:h22"
vim.g.snacks_animate = false
