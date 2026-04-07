return {
  -- fzf-lua (Ported from fzf.vim with modern improvements)
  -- This replaces telescope as per user preference (fzf-lua is better)
  {
    "ibhagwan/fzf-lua",
    -- optional: builds on 'mini.icons' for icons
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<C-p>",      "<cmd>FzfLua files<cr>",           desc = "Find Files" },
      { "<leader>o",  "<cmd>FzfLua files<cr>",           desc = "Find Files" },
      { "<leader>ff", function() require("fzf-lua").files() end, desc = "Find Files (CWD)" },
      { "<leader>fp", function() require("fzf-lua").files({ cwd = ".." }) end, desc = "Find Files (Parent)" },
      { "<leader>fF", function() require("fzf-lua").files({ cwd = require("fzf-lua").path.git_root({}) }) end, desc = "Find Files (Git Root)" },
      { "<leader>fr", "<cmd>FzfLua oldfiles<cr>",        desc = "Recent Files" },
      { "<leader>fb", function() require("fzf-lua").buffers() end, desc = "Buffers" },
      { "<leader>fg", "<cmd>FzfLua git_files<cr>",       desc = "Git Files" },
      { "<leader>ft", "<cmd>FzfLua tags<cr>",            desc = "Tags" },
      { "<leader>fh", "<cmd>FzfLua help_tags<cr>",       desc = "Help Tags" },
      { "<leader>gs", "<cmd>FzfLua git_status<cr>",      desc = "Git Status" },
      { "<leader>fw", "<cmd>FzfLua live_grep<cr>",       desc = "Live Grep" },
    },
    opts = {
      -- make it look like the modern LazyVim/fzf-lua style
      "fzf-native",
      winopts = {
        preview = {
          layout = "vertical",
          vertical = "down:45%",
        },
      },
    },
  },

  -- Neo-tree (NERDTree replacement)
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>n", "<cmd>Neotree toggle<cr>", desc = "Toggle Neo-tree" },
      { "<leader>h", "<cmd>Neotree toggle<cr>", desc = "Toggle Neo-tree" }, -- Matching user's vim mappings
    },
    opts = {
      filesystem = {
        filtered_items = {
          visible = true, -- show hidden files like Nerdtree
          hide_dotfiles = false,
          hide_gitignored = false,
        },
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
      },
      window = {
        position = "left",
        width = 30,
      },
    },
  },

  -- Flash (Modern alternative to EasyMotion)
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    ---@type Flash.Config
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end,       desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    },
  },

  -- Surround (Ported from vim-surround)
  {
    "echasnovski/mini.surround",
    opts = {
      mappings = {
        add = "sa", -- Add surrounding in Normal and Visual modes
        delete = "sd", -- Delete surrounding
        find = "sf", -- Find surrounding (to the right)
        find_left = "sF", -- Find surrounding (to the left)
        highlight = "sh", -- Highlight surrounding
        replace = "sr", -- Replace surrounding
        update_n_lines = "sn", -- Update `n_lines`
      },
    },
  },

  -- Gitsigns (Ported from gitgutter)
  {
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "-" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
      },
    },
  },

  -- Multi-cursor (Ported from vim-visual-multi)
  {
    "mg979/vim-visual-multi",
    event = "VeryLazy",
    init = function()
      -- Use default mappings (Ctrl-N)
    end,
  },
  
  -- Auto Pairs
  {
    "echasnovski/mini.pairs",
    event = "VeryLazy",
    opts = {},
  },
}
