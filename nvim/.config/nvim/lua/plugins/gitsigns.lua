return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "" },
        topdelete    = { text = "" },
        changedelete = { text = "▎" },
        untracked    = { text = "▎" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local map = function(mode, keys, func, desc)
          vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = "Git: " .. desc })
        end

        -- Navigation (Zed: ]c / [c)
        map("n", "]c", gs.next_hunk, "Next Change")
        map("n", "[c", gs.prev_hunk, "Prev Change")

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
  },
}
