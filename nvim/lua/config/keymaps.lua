-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set('n', '<C-p>', Snacks.picker.files, { noremap = true, silent = true })
vim.keymap.set('n', '<C-l>', Snacks.picker.recent, { noremap = true, silent = true })

vim.opt.shell = "/bin/zsh"

vim.keymap.set("n", "q", ":wq<CR>", { noremap = true, silent = true })

