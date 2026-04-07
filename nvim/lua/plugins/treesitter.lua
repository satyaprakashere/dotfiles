return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main", -- Required for Neovim 0.12+
    lazy = false, -- Treesitter 'main' should not be lazy loaded
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      -- Note: ensure_installed is no longer supported in 'main'
      -- Highlighting is now handled natively via vim.treesitter.start()
      -- configured in lua/config/autocmds.lua
    },
    config = function()
      -- Optional: Configure extra parser directories if needed
      -- require("nvim-treesitter").setup({})

      -- Initial install of preferred parsers
      -- This will run on first load; thereafter :TSUpdate handles it.
      local parsers = {
        "bash", "c", "clojure", "go", "haskell", "lua", "markdown",
        "markdown_inline", "python", "query", "vim", "vimdoc", "zig",
        "odin"
      }
      
      -- We use pcall to avoid errors if the tree-sitter CLI isn't ready immediately
      pcall(function()
        require("nvim-treesitter").install(parsers)
      end)
    end,
  },

  -- Context (Works with the new treesitter)
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "VeryLazy",
    opts = { mode = "cursor", max_lines = 3 },
  },
}
