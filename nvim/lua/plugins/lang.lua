return {
  -- Clojure (Ported from vim-iced/vim-sexp)
  -- Conjure is the standard Neovim replacement for iced/fireplace
  {
    "Olical/conjure",
    ft = { "clojure", "fennel", "python" }, -- and others
    lazy = true,
    init = function()
      -- Set configuration options here
      vim.g["conjure#filetype#fennel"] = "conjure.client.fennel.aniseed"
    end,
  },

  -- S-expressions
  { "guns/vim-sexp", ft = { "clojure", "fennel", "scheme", "lisp" } },
  { "tpope/vim-sexp-mappings-for-regular-people", ft = { "clojure", "fennel", "scheme", "lisp" } },

  -- Parinfer (Ported from vimrc)
  {
    "eraserhd/parinfer-rust",
    build = "cargo build --release",
    ft = { "clojure", "fennel", "scheme", "lisp" },
  },

  -- VimWiki (Ported from vimrc)
  {
    "vimwiki/vimwiki",
    event = "VeryLazy",
    init = function()
      vim.g.vimwiki_list = {
        {
          path = "~/vimwiki/",
          syntax = "markdown",
          ext = ".md",
        },
      }
    end,
  },

  -- Markdown Preview (maintained from vimrc)
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && npm install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
  },

  -- Additional language specific (lightweight alternatives)
  { "ziglang/zig.vim", ft = "zig" },
  { "elixir-editors/vim-elixir", ft = "elixir" },
  { "dag/vim2hs", ft = "haskell" },
  { "derekelkins/agda-vim", ft = "agda" },
  { "idris-hackers/idris-vim", ft = "idris" },
}
