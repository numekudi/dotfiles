return {
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    -- コマンド実行時に初めて読み込む（起動時のコストを避ける）
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewFileHistory",
      "DiffviewRefresh",
    },
    keys = {
      -- 作業ツリー全体の差分を開く。ファイルパネル付きで一覧しながらレビューする
      { "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "Diffview: Open" },
      -- main との差分。三点比較（...）で分岐点からの変更のみを見る
      { "<leader>gm", "<cmd>DiffviewOpen origin/main...HEAD<CR>", desc = "Diffview: vs origin/main" },
      -- カレントファイルのコミット履歴
      { "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", desc = "Diffview: File History" },
      -- リポジトリ全体のコミット履歴
      { "<leader>gH", "<cmd>DiffviewFileHistory<CR>", desc = "Diffview: Repo History" },
      -- ビジュアル選択した行範囲の履歴
      { "<leader>gh", "<Esc><cmd>'<,'>DiffviewFileHistory<CR>", mode = "v", desc = "Diffview: Range History" },
      { "<leader>gq", "<cmd>DiffviewClose<CR>", desc = "Diffview: Close" },
    },
    opts = {
      enhanced_diff_hl = true, -- 差分内の語単位ハイライトを有効にする
      view = {
        merge_tool = {
          -- コンフリクト解決時は 3-way（ours / base / theirs）で全体を把握する
          layout = "diff3_mixed",
          disable_diagnostics = true,
        },
      },
      file_panel = {
        listing_style = "tree",
        win_config = { position = "left", width = 35 },
      },
      keymaps = {
        view = {
          -- Diffview のタブを閉じるショートカット（各ビューで共通に効かせる）
          { "n", "q", "<cmd>DiffviewClose<CR>", { desc = "Close Diffview" } },
          { "n", "<leader>e", "<cmd>DiffviewToggleFiles<CR>", { desc = "Toggle file panel" } },
        },
        file_panel = {
          { "n", "q", "<cmd>DiffviewClose<CR>", { desc = "Close Diffview" } },
        },
        file_history_panel = {
          { "n", "q", "<cmd>DiffviewClose<CR>", { desc = "Close Diffview" } },
        },
      },
    },
  },
}
