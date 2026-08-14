return {
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    -- nvim-cmp を依存に置くことで、下の confirm_done フック登録時点で
    -- cmp が確実にロード済みであることを保証する
    dependencies = { "hrsh7th/nvim-cmp" },
    config = function()
      local autopairs = require("nvim-autopairs")

      autopairs.setup({
        -- check_ts は nvim-treesitter の旧 API (nvim-treesitter.configs /
        -- ts_utils) に依存するが、本 config の nvim-treesitter は main ブランチ
        -- (再実装版) でそれらを持たないため有効化するとエラーになる。
        check_ts = false,
        -- プロンプト系バッファでは補完が邪魔になるので無効化する
        disable_filetype = { "TelescopePrompt", "NvimTree" },
        -- 単語の直前で開きカッコを打った場合は閉じカッコを入れない (foo| で ( → (foo)
        -- ではなく (foo と同じ挙動にしたいケースを避ける)
        ignored_next_char = "[%w%.%(%[%{]",
        fast_wrap = {
          -- 挿入モードで <M-e> を押すと、直後のテキストをカッコで囲む
          map = "<M-e>",
        },
      })
      -- 補完で関数/メソッドを確定したとき、続けて () を挿入する
      local cmp = require("cmp")
      cmp.event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done())
    end,
  },
}
