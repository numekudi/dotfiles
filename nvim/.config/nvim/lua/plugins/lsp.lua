return {
  {
    "williamboman/mason.nvim",
    opts = {},
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      vim.api.nvim_create_autocmd("CursorHold", {
        callback = function()
          vim.diagnostic.open_float(nil, { focusable = false, scope = "cursor" })
        end,
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufnr = args.buf
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
          end
          map("gd", function()
            require("telescope.builtin").lsp_definitions()
          end, "Go to Definition")
          map("K", vim.lsp.buf.hover, "Hover Documentation")
          map("<leader>rn", vim.lsp.buf.rename, "Rename")
          map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
          map("<leader>f", function()
            vim.lsp.buf.format({ async = true })
          end, "Format")
          vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, { buffer = bufnr, desc = "LSP: Rename" })
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({ async = false, bufnr = bufnr })
            end,
          })
        end,
      })

      -- promptls: Claude Code / Codex の Ctrl+G で開く一発プロンプト向け。
      -- Claude Code は `$TMPDIR/claude-prompt-*.md`、Codex は `/tmp/.tmpXXXX.md` を
      -- 作るので「一時ディレクトリ直下の .md」を対象にする。@path のファジー補完・
      -- 存在チェック・hover・gd を提供する。プロジェクトルートは promptls 自身が
      -- 決める（通常は nvim の cwd = CLI を起動したプロジェクト。違う場所から
      -- 起動された場合は親プロセスの cwd をたどる）。
      -- ~/GitHub/prompt-lsp から `cargo install --path .` でインストール。
      vim.lsp.config("promptls", {
        cmd = { "promptls" },
        filetypes = { "markdown" },
        capabilities = capabilities,
        -- markdown 全般ではなく一時ディレクトリ配下の .md にだけ付ける
        root_dir = function(bufnr, on_dir)
          local name = vim.api.nvim_buf_get_name(bufnr)
          if not name:match("%.md$") then
            return
          end
          -- Claude Code (Node os.tmpdir) も Codex (Rust temp_dir) も
          -- $TMPDIR があればそれ、無ければ /tmp を使うので同じ規則で判定する。
          -- macOS では /tmp -> /private/tmp のシンボリックリンクなので実体パスでも比較する
          local tmpdir = (os.getenv("TMPDIR") or "/tmp"):gsub("/*$", "/")
          local real_tmpdir = (vim.uv.fs_realpath(tmpdir) or tmpdir):gsub("/*$", "/")
          local real_name = vim.uv.fs_realpath(name) or name
          if vim.startswith(name, tmpdir) or vim.startswith(real_name, real_tmpdir) then
            -- nvim 側の root_dir は形式的なもの。実際の解決は promptls が行う。
            on_dir(vim.fn.getcwd())
          end
        end,
      })
      vim.lsp.enable("promptls")

      require("mason-lspconfig").setup({
        -- vtsls bundles its own TypeScript, so no global/per-project `typescript`
        -- install is needed (ts_ls required an external tsserver and failed to start).
        ensure_installed = { "lua_ls", "vtsls", "pyright" },
        automatic_installation = true,
        handlers = {
          function(server_name)
            lspconfig[server_name].setup({ capabilities = capabilities })
          end,
        },
      })
    end,
  },
}
