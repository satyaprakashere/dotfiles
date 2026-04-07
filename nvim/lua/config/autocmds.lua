-- Custom Autocommands (Ported from Vim settings and functions)

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Jump to last position when reopening a file
autocmd("BufReadPost", {
  group = augroup("LastPos", { clear = true }),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local line_count = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Language specific settings
autocmd("FileType", {
  pattern = { "sh", "haskell", "python", "rekursion" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
  end,
})

autocmd("FileType", {
  pattern = "swift",
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.expandtab = true
  end,
})

-- Fix path (macOS specific)
vim.env.PATH = vim.env.PATH .. ":" .. vim.fn.expand("~/.ghcup/bin")
vim.env.PATH = vim.env.PATH .. ":" .. "/opt/homebrew/bin"

-- Project Files searching (equivalent to s:project_files in functions.vim)
-- This logic will be largely superseded by fzf-lua, but let's keep it here for awareness
-- and use it in custom fzf-lua wrappers if needed.

-- Formatting on save (equivalent to coc-settings.json)
-- This will be handled by conform.nvim in Phase 2

-- Highlight on yank
autocmd("TextYankPost", {
  group = augroup("HighlightYank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Check if we need to reload the file when it changed exteriorly
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("CheckTime", { clear = true }),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- Treesitter highlighting (Neovim 0.12+ Native)
autocmd("FileType", {
  group = augroup("TSHighlight", { clear = true }),
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    pcall(vim.treesitter.start, buf)
  end,
})
