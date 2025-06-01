-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.opt.shell = "/bin/zsh"

vim.keymap.set("n", "q", ":wq<CR>", { noremap = true, silent = true })

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>fp", builtin.commands, { desc = "Telescope commands" })
vim.keymap.set("n", "<C-p>", builtin.commands, { desc = "Telescope commands" })

vim.keymap.set("n", "<C-l>", builtin.find_files, { desc = "Telescope find files" })
