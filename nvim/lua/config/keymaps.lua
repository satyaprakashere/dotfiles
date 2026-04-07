-- Custom Mappings (Ported from Vim 3.0_mappings.vim + Plugin equivalents)

local map = vim.keymap.set

-- Overriding existing mappings
map({"n", "v"}, "<Up>", "<NOP>")
map({"n", "v"}, "<Down>", "<NOP>")
map({"n", "v"}, "<Left>", "<NOP>")
map({"n", "v"}, "<Right>", "<NOP>")

map("i", "<C-c>", "<ESC>")
map("c", "<C-c>", "<ESC>")

map("n", "q", ":q<CR>")
map("n", ";", ":")
map("i", "jk", "<ESC>")

-- Update existing mappings
-- Do not leave visual mode after shifting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Make Y consistent with C and D
map("n", "Y", "y$")

-- Move through display lines
map("n", "j", "gj")
map("n", "k", "gk")
map("n", "gj", "j")
map("n", "gk", "k")

map("n", "<C-h>", ":nohls<CR>")

-- Map 'gb' to Go Back in the jump list (Ctrl + O)
map("n", "gb", "<C-o>")

-- Leader mappings
map("n", "<leader>b", ":!bash ~/dotfiles/shell/build-scripts/build.sh %<CR>", { desc = "Build File" })
map("n", "<leader>r", ":!bash ~/dotfiles/shell/build-scripts/build_run.sh %<CR>", { desc = "Build and Run" })

map("n", "<leader>q", ":bd<CR>", { desc = "Close Buffer" })
map("n", "<leader>.", ":!open .<CR>", { desc = "Open Directory in Finder" })
map("n", "<leader>vp", ":vsp<CR>", { desc = "Vertical Split" })
map("n", "<leader>sp", ":sp<CR>", { desc = "Horizontal Split" })
map("n", "<leader>bn", ":bn<CR>", { desc = "Next Buffer" })
map("n", "<leader>bp", ":bp<CR>", { desc = "Previous Buffer" })
map("n", "<leader>bl", ":buffers<CR>", { desc = "List Buffers" })
map("n", "<leader>s", ":w<CR>", { desc = "Save File" })

-- Re-select pasted/edited text block
map("n", "<leader>gv", "`[v`]", { desc = "Re-select Last Paste" })

-- Re-format paragraphs of text
map("n", "<leader>gq", "gqip", { desc = "Re-format Paragraph" })

-- Clean trailing whitespace and retab
map("n", "<leader>wt", ":silent! %s/\\s\\+$// | retab <CR>", { desc = "Cleanup Whitespace" })

-- Command Mode navigation
map("c", "<C-k>", "<Up>")
map("c", "<C-j>", "<Down>")

-- GUI Specific (using D- for Command key)
map({"n", "v", "i"}, "<D-d>", "<cmd>vsp<CR>")
map({"n", "v", "i"}, "<D-l>", "<cmd>buffers<CR>")
map({"n", "v", "i"}, "<D-j>", "<C-w>l")
map({"n", "v", "i"}, "<D-k>", "<C-w>h")
map("n", "<D-b>", ":!bash ~/dotfiles/shell/build-scripts/build.sh %<CR>")
map("n", "<D-r>", ":!bash ~/dotfiles/shell/build-scripts/build_run.sh %<CR>")
map("n", "<D-h>", "<cmd>Neotree toggle<CR>") -- Will setup Neotree as NERDTree replacement

-- Plugin mappings will be defined inside plugin configs, but let's keep core ones here
-- <C-p> for Files will be handled by fzf-lua in Phase 2
