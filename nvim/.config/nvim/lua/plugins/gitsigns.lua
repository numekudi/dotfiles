return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add          = { text = '┃' },
        change       = { text = '┃' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
        untracked    = { text = '┆' },
      },
      -- サイン列の色を Git の意味に合わせて固定する
      -- Added=緑 / Modified(change)=黄 / Deleted=赤
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local map = function(mode, keys, func, desc)
          vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = "Git: " .. desc })
        end

        -- Navigation (Zed: ]c / [c)
        map("n", "]c", gs.next_hunk, "Next Change")
        map("n", "[c", gs.prev_hunk, "Prev Change")
        map("n", "dn", gs.next_hunk, "Next Change")
        map("n", "dN", gs.prev_hunk, "Prev Change")
        -- Expand diff hunk (Zed: do)
        map("n", "do", gs.preview_hunk, "Expand Diff Hunk")

        -- Toggle staged (Zed: dO)
        map("n", "dO", gs.stage_hunk, "Toggle Staged")
        map("v", "dO", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Toggle Staged")

        -- Stage and next (Zed: du)
        map("n", "du", function()
          gs.stage_hunk()
          gs.next_hunk()
        end, "Stage and Next")

        -- Unstage and next (Zed: dU)
        map("n", "dU", function()
          gs.undo_stage_hunk()
          gs.next_hunk()
        end, "Unstage and Next")

        -- Restore change (Zed: dp)
        map("n", "dp", gs.reset_hunk, "Restore Change")
        map("v", "dp", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Restore Change")

        -- Extra
        map("n", "<leader>hS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>hR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame Line")
        map("n", "<leader>hd", gs.diffthis, "Diff This")

        -- Text object
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select Hunk")
      end,
    },
    config = function(_, opts)
      require("gitsigns").setup(opts)

      -- gitsigns のサイン色を明示指定する
      -- 既定ではカラースキームの Diff 系にリンクされ色が意図とずれるため上書きする
      local function set_signs_colors()
        vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = "#00b04f" })    -- Added: 緑
        vim.api.nvim_set_hl(0, "GitSignsChange", { fg = "#e0af68" })  -- Modified: 黄
        vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = "#f7768e" })  -- Deleted: 赤
      end

      set_signs_colors()
      -- カラースキーム切り替え時にハイライトが再定義され色が戻るため、その都度適用する
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = set_signs_colors,
      })
    end,
  },
}
