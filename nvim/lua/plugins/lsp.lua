return {
  -- Native LSP Config (Modern 0.12+ style)
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    opts = {
      -- LSP Server configurations
      servers = {
        pyright = {},
        hls = {},
        gopls = {},
        zls = {},
        ols = {}, -- Odin Language Server
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                globals = { "vim", "Snacks" },
              },
            },
          },
        },
      },
    },
    config = function(_, opts)
      -- Neovim 0.12+ Native Configuration
      -- This replaces the old lspconfig[server].setup() pattern

      for server, server_opts in pairs(opts.servers) do
        -- 1. Modify the native config for each server if specific opts are provided
        if next(server_opts) ~= nil then
          vim.lsp.config(server, server_opts)
        end
        
        -- 2. Enable the server natively
        vim.lsp.enable(server)
      end

      -- Diagnostic configuration (Modern way)
      vim.diagnostic.config({
        underline = true,
        update_in_insert = false,
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = "●",
        },
        severity_sort = true,
      })

      -- Custom mappings pointing to native LSP (Ported from CoC mappings)
      -- Note: Neovim 0.12 already provides 'grn', 'grr', 'gri', etc.
      local map = vim.keymap.set
      map("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
      map("n", "gy", vim.lsp.buf.type_definition, { desc = "Go to Type Definition" })
      map("n", "gi", vim.lsp.buf.implementation, { desc = "Go to Implementation" })
      map("n", "gr", vim.lsp.buf.references, { desc = "Go to References" })
      map("n", "K", vim.lsp.buf.hover, { desc = "Hover Documentation" })
      map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename Symbol" })
      map({ "n", "v" }, "<leader>f", function()
        require("conform").format({ lsp_fallback = true })
      end, { desc = "Format Selection/Buffer" })
    end,
  },

  -- Mason (Management of LSP/Linters/Formatters)
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    opts = {
      ensure_installed = {
        "pyright",
        "haskell-language-server",
        "gopls",
        "zls",
        "lua-language-server",
        "ols", -- Odin
        "stylua",
        "isort",
        "black",
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      for _, tool in ipairs(opts.ensure_installed) do
        local p = mr.get_package(tool)
        if not p:is_installed() then
          p:install()
        end
      end
    end,
  },

  -- Blink.cmp (The Modern Completion Engine)
  {
    "saghen/blink.cmp",
    dependencies = "rafamadriz/friendly-snippets",
    version = "*",
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = "default",
        ["<TAB>"] = { "select_next", "fallback" },
        ["<S-TAB>"] = { "select_prev", "fallback" },
      },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
    },
  },

  -- Conform (Modern and fast Formatter)
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "isort", "black" },
        go = { "gofmt", "goimports" },
        haskell = { "ormolu" },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    },
  },
}
