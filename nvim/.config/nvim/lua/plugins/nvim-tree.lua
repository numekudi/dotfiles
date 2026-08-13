return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- Disable netrw
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      require("nvim-tree").setup({
        sort = { sorter = "case_sensitive" },
        view = { width = 30 },
        renderer = {
          group_empty = true,
          icons = { show = { git = true } },
        },
        filters = { dotfiles = false },
        git = { enable = true, ignore = false },
        -- アクティブなバッファのファイルをツリー上でも展開・選択する
        -- update_root = false: プロジェクト外のファイルを開いてもルートを動かさない
        update_focused_file = { enable = true, update_root = false },
      })

      vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle File Explorer" })
      vim.keymap.set("n", "<leader>E", "<cmd>NvimTreeFindFile<CR>", { desc = "Find File in Explorer" })
    end,
  },
}
