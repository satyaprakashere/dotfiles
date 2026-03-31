-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "q", ":wq<CR>", { noremap = true, silent = true })

-- Telescope
-- local builtin = require("telescope.builtin")
-- vim.keymap.set("n", "<leader>fp", builtin.commands, { desc = "Telescope commands" })
-- vim.keymap.set("n", "<C-p>", builtin.commands, { desc = "Telescope commands" })
-- vim.keymap.set("n", "<C-l>", builtin.find_files, { desc = "Telescope find files" })

-- Save
vim.keymap.set("n", "<D-s>", ":w<CR>", { noremap = true })

-- Terminal split
vim.keymap.set("n", "<C-j>", function()
  local height = math.floor(vim.o.lines * 0.4) - 2 -- Subtracting for UI space
  vim.cmd("split") -- Create a bottom split
  vim.cmd("resize " .. height) -- Resize to 40% of total lines
  vim.cmd("terminal") -- Start terminal
  vim.cmd("startinsert") -- Auto-enter insert mode
end, { noremap = true, silent = true })
