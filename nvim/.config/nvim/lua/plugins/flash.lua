return {
  {
    -- easymotion 系の後継。ラベルジャンプを検索と統合した実装
    "folke/flash.nvim",
    event = "VeryLazy",
    ---@type Flash.Config
    opts = {
      -- `/` や `f` などの標準モーションは既定挙動のまま残し、
      -- ラベルジャンプは明示したキーからのみ起動する
      modes = {
        search = { enabled = false },
        char = { enabled = false },
      },
      label = {
        -- 入力済みの文字列の前後どちらにもラベルを出し、手前側を優先する
        before = true,
        after = false,
      },
    },
    keys = {
      -- easymotion 相当の本体。<leader><leader> のあとに検索文字を打つとラベルが出る
      {
        "<leader><leader>",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash: Jump",
      },
      -- Treesitter ノード単位の選択。関数や式のまとまりを一発で掴む
      -- <leader><leader> の後続キーは flash 自身が検索文字として食うため、別プレフィクスに置く
      {
        "<leader>st",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash: Treesitter select",
      },
    },
  },
}
