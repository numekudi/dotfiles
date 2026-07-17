return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    -- カラースキームは他プラグインより先に読み込む必要があるため優先度を上げる
    priority = 1000,
    opts = {
      -- 定番のダーク系フレーバー（latte/frappe/macchiato/mocha から選択可能）
      flavour = "mocha",
      styles = {
        -- function や return などのイタリック表示を無効にする
        functions = {},
        keywords = {},
        conditionals = {},
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
  },
}
