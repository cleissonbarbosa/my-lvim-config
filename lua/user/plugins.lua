-- ============================================================================
-- PLUGINS
-- Anything LunarVim does not already bundle. Specs are lazy-loaded whenever the
-- plugin supports it, so startup stays close to a bare LunarVim.
-- ============================================================================

lvim.plugins = {

  -- =========================================================================
  -- Editing
  -- =========================================================================

  -- Multi-cursor
  { "mg979/vim-visual-multi" },

  -- Surround: add/remove/change delimiters
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup()
    end,
  },

  -- Fast in-file navigation
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end,       desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    },
  },

  -- Auto close/rename HTML and JSX tags
  {
    "windwp/nvim-ts-autotag",
    ft = {
      "html", "xml", "javascript", "javascriptreact",
      "typescript", "typescriptreact", "svelte", "vue", "markdown",
    },
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },

  -- Project-wide search and replace with a live preview buffer
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    opts = { headerMaxWidth = 80 },
  },

  -- =========================================================================
  -- Navigation and sessions
  -- =========================================================================

  -- Pin a handful of files and jump straight to them
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "VeryLazy",
    config = function()
      require("harpoon"):setup()
    end,
  },

  -- Restore buffers/layout per project directory
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    -- What gets saved comes from vim.o.sessionoptions (see user/options.lua)
    opts = {},
  },

  -- Browse the undo tree through telescope
  {
    "debugloop/telescope-undo.nvim",
    -- The dependency guarantees telescope is configured before load_extension
    dependencies = { "nvim-telescope/telescope.nvim" },
    event = "VeryLazy",
    config = function()
      require("telescope").load_extension("undo")
    end,
  },

  -- Context bar (sticky breadcrumbs on top)
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufRead",
    config = function()
      require("treesitter-context").setup({
        max_lines = 3,
      })
    end,
  },

  -- =========================================================================
  -- UI
  -- =========================================================================

  -- Inline preview of color literals
  {
    "catgoose/nvim-colorizer.lua",
    event = "BufReadPre",
    opts = {
      filetypes = { "css", "scss", "html", "javascript", "typescript",
        "javascriptreact", "typescriptreact", "lua", "conf", "toml" },
      user_default_options = {
        css = true,
        tailwind = true,
        mode = "background",
      },
    },
  },

  -- Distraction-free writing/reading
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    opts = {
      window = { width = 120 },
      plugins = { options = { laststatus = 0 } },
    },
  },

  -- Highlight TODO, FIXME, HACK, etc.
  {
    "folke/todo-comments.nvim",
    event = "BufRead",
    config = function()
      require("todo-comments").setup()
    end,
  },

  -- Organized diagnostics UI
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    config = function()
      require("trouble").setup()
    end,
  },

  -- Markdown rendering in the editor
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      latex = { enabled = false }, -- disable latex (avoids parser/utftex missing warnings)
    },
  },

  -- =========================================================================
  -- Git
  -- LunarVim already ships gitsigns and a lazygit toggle (<leader>gg).
  -- =========================================================================

  -- Side-by-side diffs and file/branch history
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles" },
    opts = {
      enhanced_diff_hl = true,
      view = {
        merge_tool = { layout = "diff3_mixed" },
      },
    },
  },

  -- =========================================================================
  -- Tooling: Mason
  -- =========================================================================

  -- Provisions every Mason package this config expects, so a fresh clone comes
  -- up complete. Language servers are listed here on purpose: LunarVim's
  -- lsp_manager auto-installer runs before Mason has refreshed its registry and
  -- fails on a cold start, while mason-tool-installer waits for the refresh.
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = {
          -- Language servers (Mason package names, not lspconfig names)
          "lua-language-server",
          "gopls",
          "ruff",                          -- Python lint/format/imports, runs as LSP
          "typescript-language-server",
          "html-lsp",
          "css-lsp",
          "json-lsp",
          "yaml-language-server",
          "bash-language-server",
          "dockerfile-language-server",
          "tailwindcss-language-server",
          "emmet-ls",
          "taplo",                         -- TOML: LSP + formatter
          "marksman",                      -- Markdown

          -- Formatters
          "stylua",                        -- Lua
          "goimports",                     -- Go
          "prettierd",                     -- Web (JS/TS/HTML/CSS/JSON/YAML/MD)
          "shfmt",                         -- Shell

          -- Linters
          "golangci-lint",                 -- Go
          "eslint_d",                      -- JS/TS
          "shellcheck",                    -- Shell
          "hadolint",                      -- Dockerfile
          "markdownlint",                  -- Markdown
          "yamllint",                      -- YAML
        },
        auto_update = false,
        run_on_start = true,
      })
    end,
  },

  -- =========================================================================
  -- Debugging (nvim-dap and nvim-dap-ui already ship with LunarVim)
  -- =========================================================================

  -- Install the debug adapters through Mason. handlers = {} on purpose:
  -- adapters are registered explicitly in user/dap.lua and by the two
  -- language-specific plugins below, so nothing gets configured twice.
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = { "williamboman/mason.nvim", "mfussenegger/nvim-dap" },
    event = "VeryLazy",
    config = function()
      require("mason-nvim-dap").setup({
        ensure_installed = { "delve", "python", "codelldb", "js" },
        automatic_installation = true,
        handlers = {},
      })
    end,
  },

  -- Show variable values inline while stepping
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = { "mfussenegger/nvim-dap" },
    event = "VeryLazy",
    opts = {
      commented = true,
      virt_text_pos = "eol",
    },
  },

  -- Go: debug the test/function under the cursor
  {
    "leoluz/nvim-dap-go",
    ft = "go",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("dap-go").setup()
    end,
  },

  -- Python: resolves debugpy and adds pytest helpers
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local debugpy = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
      require("dap-python").setup(vim.fn.executable(debugpy) == 1 and debugpy or "python3")
    end,
  },

  -- =========================================================================
  -- Testing
  -- =========================================================================

  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "fredrikaverpil/neotest-golang",
      "nvim-neotest/neotest-python",
      "nvim-neotest/neotest-jest",
      "marilari88/neotest-vitest",
    },
    cmd = "Neotest",
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-golang")({
            dap_go_enabled = true,
          }),
          require("neotest-python")({
            dap = { justMyCode = false },
            runner = "pytest",
          }),
          require("neotest-jest")({
            jestCommand = "npm test --",
          }),
          require("neotest-vitest"),
        },
        output = { open_on_run = false },
        quickfix = { enabled = false },
      })
    end,
  },

  -- =========================================================================
  -- Language specific
  -- =========================================================================

  -- Go: struct tags, impl, iferr, test generation
  {
    "olexsmir/gopher.nvim",
    ft = "go",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("gopher").setup()
    end,
  },

  -- Rust: replaces the archived rust-tools. It owns rust-analyzer entirely,
  -- which is why rust_analyzer is skipped in user/lsp.lua.
  {
    "mrcjkb/rustaceanvim",
    version = "^9",
    lazy = false, -- the plugin manages its own lazy loading
    init = function()
      vim.g.rustaceanvim = {
        server = {
          on_attach = function(client, bufnr)
            require("lvim.lsp").common_on_attach(client, bufnr)
          end,
          default_settings = {
            ["rust-analyzer"] = {
              cargo = {
                allFeatures = true,
                buildScripts = { enable = true },
              },
              checkOnSave = true,
              check = {
                command = "clippy",
                extraArgs = { "--no-deps" },
              },
              procMacro = { enable = true },
              inlayHints = {
                lifetimeElisionHints = { enable = "skip_trivial" },
                closureReturnTypeHints = { enable = "with_block" },
              },
            },
          },
        },
        -- Debugging comes from codelldb, which rustaceanvim discovers in Mason
        -- on its own. Install it once (mason-nvim-dap does) and
        -- `:RustLsp debuggables` works.
      }
    end,
  },

  -- =========================================================================
  -- AI: GitHub Copilot
  -- =========================================================================

  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      -- Resolved lazily: this shells out to bash and used to cost ~200ms on
      -- every startup, even when Copilot was never touched.
      local node_path = vim.fn.trim(vim.fn.system(
        "bash -lc 'export NVM_DIR=\"$HOME/.nvm\"; "
          .. "[ -s \"$NVM_DIR/nvm.sh\" ] && . \"$NVM_DIR/nvm.sh\"; "
          .. "nvm which stable 2>/dev/null || command -v node'"
      ))

      require("copilot").setup({
        copilot_node_command = node_path ~= "" and node_path or "node",
        suggestion = { enabled = false }, -- suggestions come through nvim-cmp
        panel = { enabled = false },
      })
    end,
  },

  -- Copilot as an nvim-cmp source
  {
    "zbirenbaum/copilot-cmp",
    dependencies = { "zbirenbaum/copilot.lua" },
    config = function()
      require("copilot_cmp").setup()
    end,
  },

  -- Copilot Chat
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim" },
    },
    config = function()
      require("CopilotChat").setup({
        show_help = "yes",
        question_header = "  Você ",
        answer_header = "   Copilot ",
        error_header = "  Erro ",
        highlight_selection = true,
        selection = require("CopilotChat.select").visual,
        window = {
          layout = "vertical",
          width = 0.4,
          relative = "editor",
          side = "right",
          border = "none",
        },
      })

      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "copilot-*",
        callback = function()
          vim.opt_local.relativenumber = false
        end,
      })
    end,
  },
}
