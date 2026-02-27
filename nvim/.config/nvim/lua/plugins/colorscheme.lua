-- カラースキームの設定
-- priority = 1000 で他のプラグインより先にロードする
return {
  -- Tokyo Night (デフォルト有効)
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    opts = {
      style = "night", -- "storm" | "night" | "moon" | "day"
      transparent = false,
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight")
    end,
  },

  -- 他のテーマ候補（使いたい場合は上のブロックをコメントアウトして有効化）

  -- Catppuccin
  -- {
  --   "catppuccin/nvim",
  --   name = "catppuccin",
  --   priority = 1000,
  --   opts = { flavour = "mocha" }, -- "latte" | "frappe" | "macchiato" | "mocha"
  --   config = function(_, opts)
  --     require("catppuccin").setup(opts)
  --     vim.cmd.colorscheme("catppuccin")
  --   end,
  -- },

  -- Gruvbox
  -- {
  --   "ellisonleao/gruvbox.nvim",
  --   priority = 1000,
  --   opts = { contrast = "hard" }, -- "" | "soft" | "hard"
  --   config = function(_, opts)
  --     require("gruvbox").setup(opts)
  --     vim.cmd.colorscheme("gruvbox")
  --   end,
  -- },

  -- Kanagawa
  -- {
  --   "rebelot/kanagawa.nvim",
  --   priority = 1000,
  --   config = function()
  --     vim.cmd.colorscheme("kanagawa")
  --   end,
  -- },
}
