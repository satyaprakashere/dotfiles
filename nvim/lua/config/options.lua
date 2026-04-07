-- Generic Neovim Options (Ported from Vim 1.0_settings.vim)

local opt = vim.opt

-- General
opt.timeoutlen = 300 -- Faster mapping timeout (default is 1000ms)

-- Appearance
opt.termguicolors = true
opt.cursorline = true
opt.number = true
opt.relativenumber = true
opt.colorcolumn = "85"
opt.laststatus = 3 -- Neovim 0.12+ supports a global statusline
opt.shortmess:append("I") -- No intro message
opt.showcmd = true
opt.showmatch = true
opt.scrolloff = 10 -- Better context while scrolling
opt.sidescrolloff = 8 -- Better context while scrolling horizontally
opt.display = "lastline"
opt.lazyredraw = true -- Faster UI
opt.wrap = true
opt.whichwrap:append("h,l,~,[,]")
opt.list = true
opt.listchars = { tab = "» ", trail = "·" }

-- Editing
vim.g.mapleader = " " -- Set Leader to Space
opt.autoindent = true
opt.backspace = { "indent", "eol", "start" }
opt.completeopt = { "menu", "menuone", "noselect", "preview" }
opt.expandtab = true
opt.shiftwidth = 4
opt.softtabstop = 4
opt.tabstop = 4
opt.shiftround = true
opt.smarttab = true
opt.textwidth = 100
opt.formatoptions:append("qrn12")
opt.modeline = true
opt.modelines = 1

-- Clipboard (macOS focused)
opt.clipboard = "unnamed"
opt.mouse = "a"

-- Buffer & Search
opt.hidden = true
opt.autochdir = true
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.autoread = true
opt.autowriteall = true
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.splitright = true
opt.splitbelow = true
opt.wildmenu = true
opt.wildmode = { "longest:full", "full" }
opt.wildignore = { "*.o", "*.obj", "*~", "*.so", "*.swp", "*.zip", "*.out", "*.pdf" }

-- Undo persistence (Unlimited Undo)
opt.undofile = true
opt.undolevels = 10000
opt.undoreload = 10000
opt.undodir = vim.fn.stdpath("state") .. "/undo"

-- Language specific defaults
vim.g.tex_flavor = "latex"

-- Disable some built-in neovim features that are annoying for some
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Smooth scrolling (native in 0.12)
opt.smoothscroll = true

-- Treesitter folding (Neovim 0.12+)
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99 -- Initial fold level (start unfolded)

-- Neovide / GUI Settings
if vim.g.neovide then
  -- Using Underscore style for robust font loading in Neovide
  vim.o.guifont = "Hack_Nerd_Font:h18"

  -- Modern GUI enhancements
  vim.g.neovide_cursor_animation_length = 0.08
  vim.g.neovide_cursor_trail_size = 0.4
  vim.g.neovide_scroll_animation_length = 0.2
end
