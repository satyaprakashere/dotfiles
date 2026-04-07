return {
  -- Catppuccin (Ported from 1.0_settings.vim)
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = false,
      term_colors = true,
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        notify = false,
        mini = {
          enabled = true,
          indentscope_color = "",
        },
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin-mocha")
    end,
  },

  -- Lualine (Statusline - Premium 'Bubble' style)
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "catppuccin" }, -- Ensure theme is loaded first
    opts = function()
      local icons = {
        git = { added = " ", modified = " ", removed = " " },
      }
      -- Check if catppuccin theme is available for lualine
      local lualine_theme = "auto"
      if pcall(require, "lualine.themes.catppuccin") then
        lualine_theme = "catppuccin"
      end

      return {
        options = {
          theme = lualine_theme,
          component_separators = "",
          section_separators = { left = "", right = "" },
          globalstatus = true,
          disabled_filetypes = { statusline = { "dashboard", "alpha", "starter" } },
        },
        sections = {
          lualine_a = { { "mode", separator = { left = "" }, right_padding = 2 } },
          lualine_b = { "filename", "branch" },
          lualine_c = {
            "%=", -- center alignment
            {
              function()
                local reg = vim.fn.reg_recording()
                if reg == "" then return "" end
                return " Recording @" .. reg
              end,
              color = { fg = "#f38ba8", gui = "bold" }, -- Catppuccin Red
            },
          },
          lualine_x = {
            {
              "diagnostics",
              symbols = { error = " ", warn = " ", hint = " ", info = " " },
            },
            { "filetype", icon_only = true },
          },
          lualine_y = { "progress" },
          lualine_z = { { "location", separator = { right = "" }, left_padding = 2 } },
        },
      }
    end,
  },

  -- Snacks.nvim (The Modern Utility Belt)
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      bigfile = { enabled = true },
      dashboard = { enabled = true },
      indent = { enabled = true },
      input = { enabled = true },
      notifier = { enabled = true, timeout = 3000 },
      quickfile = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
      styles = {
        notification = {
          wo = { wrap = true } -- Wrap notifications
        }
      }
    },
    keys = {
      { "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
      { "<leader>un", function() Snacks.notifier.show_history() end, desc = "Notification History" },
      { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
      { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File" },
      { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse" },
      { "<leader>lg", function() Snacks.lazygit() end, desc = "Lazygit" },
    },
  },

  -- Icons
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- Better UI for input and select
  { "stevearc/dressing.nvim", lazy = true },

  -- Which-Key (Visual helper for leader mappings)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>b", group = "Build/Buffer" },
        { "<leader>f", group = "Find" },
        { "<leader>g", group = "Git/General" },
        { "<leader>q", group = "Quit/Delete" },
        { "<leader>s", group = "Save/Split" },
        { "<leader>u", group = "UI/Toggles" },
      },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },
}
