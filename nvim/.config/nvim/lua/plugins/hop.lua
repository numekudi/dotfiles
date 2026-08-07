return {
  {
    -- ラベルジャンプ。flash.nvim から乗り換え。
    -- flash は検索と統合されている（打鍵ごとに候補を絞り込む）ぶん処理が重く、
    -- 固定パターンで一発だけラベルを振る今回の用途では hop の方が素直で速い。
    -- 同条件（可視50行・約770候補）の実測で 5.9ms → 1.4ms。
    "smoka7/hop.nvim",
    -- phaazon/hop.nvim は開発終了しており、smoka7 がメンテナンスを引き継いでいる
    opts = {
      -- 候補以外を暗くする演出はウィンドウ全体の再描画を伴うため切る
      dim_unmatched = false,
      -- 対象は現在のウィンドウのみ。候補数が増えるとラベルが 2 桁化して本文を潰す
      multi_windows = false,
      -- 候補が 1 つしかないときは確認を挟まずそこへ飛ぶ
      jump_on_sole_occurrence = true,
      -- hop-yank / hop-treesitter は導入していない。
      -- 既定値のままだと require に失敗してエラー通知が出る
      extensions = {},
    },
    keys = {
      {
        "<leader><leader>",
        mode = { "n", "x" },
        function()
          local hop = require("hop")
          -- 日本語は空白で単語が区切られないため、hop 標準の `\k\+`（単語 = キーワード文字の連なり）
          -- では「私は特別強いエンジニアではありません」が丸ごと 1 候補になってしまい使えない。
          -- 代わりに文字種の切り替わりを単語境界とみなし、
          -- 漢字 / カタカナ / 英数字それぞれの連なりの先頭を候補にする。
          -- ひらがなは候補から外す: 助詞や送り仮名まで拾うと候補が倍増し、
          -- ラベルが 2 桁化して本文を読めなくする割に足場としての価値が低い。
          -- カタカナ類には長音符「ー」を含める（含めないと「アップロード」が 2 候補に割れる）。
          local re = vim.regex("\\v<\\w+|[一-龥]+|[ァ-ヶー]+")
          hop.hint_with_regex({
            -- oneshot=false: 1 行につき複数の候補を拾う
            oneshot = false,
            match = function(s)
              return re:match_str(s)
            end,
          }, hop.opts)
        end,
        desc = "Hop: Jump to word (JP aware)",
      },
    },
  },
}
