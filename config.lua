-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Example configs: https://github.com/LunarVim/starter.lvim
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny

-- ============================================================================
-- GENERAL SETTINGS
-- ============================================================================

-- Colorscheme
lvim.colorscheme = "tokyonight-night"

-- Vim options
vim.opt.relativenumber = true      -- Relative line numbers
vim.opt.wrap = false               -- Disable line wrapping
vim.opt.scrolloff = 8              -- Keep 8 lines visible above/below cursor
vim.opt.sidescrolloff = 8          -- Keep 8 columns visible horizontally
vim.opt.shiftwidth = 2             -- Indentation width
vim.opt.tabstop = 2                -- Tab width
vim.opt.expandtab = true           -- Convert tabs to spaces
vim.opt.timeoutlen = 300           -- Key sequence timeout (ms)
vim.opt.clipboard = "unnamedplus" -- Use system clipboard
vim.opt.cursorline = true          -- Highlight current line
vim.opt.termguicolors = true       -- Enable true colors
vim.opt.ignorecase = true          -- Case-insensitive search
vim.opt.smartcase = true           -- Case-sensitive when uppercase is used
vim.opt.undofile = true            -- Persistent undo history

-- Format on save
lvim.format_on_save.enabled = true
lvim.format_on_save.pattern = {
  "*.lua", "*.py", "*.go", "*.rs",
  "*.ts", "*.tsx", "*.js", "*.jsx",
  "*.html", "*.css", "*.json",
}

-- Set Node path for Neovim/LunarVim (auto-detected via nvm)
local node_path = vim.fn.trim(vim.fn.system("which node"))
if node_path ~= "" then
  vim.g.node_host_prog = node_path
end

-- ============================================================================
-- KEYMAPS
-- ============================================================================

-- Visual mode: move selected lines up/down
lvim.keys.visual_mode["<C-Down>"] = ":m '>+1<CR>gv=gv"
lvim.keys.visual_mode["<C-Up>"] = ":m '<-2<CR>gv=gv"

-- Normal mode: move current line up/down
lvim.keys.normal_mode["<C-Down>"] = ":m .+1<CR>=="
lvim.keys.normal_mode["<C-Up>"] = ":m .-2<CR>=="

-- Save with Ctrl+S
lvim.keys.normal_mode["<C-s>"] = ":w<CR>"
lvim.keys.insert_mode["<C-s>"] = "<Esc>:w<CR>a"

-- Keep selection after indenting in visual mode
lvim.keys.visual_mode["<"] = "<gv"
lvim.keys.visual_mode[">"] = ">gv"

-- Navigate between buffers with Shift+H and Shift+L
lvim.keys.normal_mode["<S-h>"] = ":BufferLineCyclePrev<CR>"
lvim.keys.normal_mode["<S-l>"] = ":BufferLineCycleNext<CR>"

-- Which-Key: extra leader shortcuts
lvim.builtin.which_key.mappings["t"] = {
  name = "+Terminal/Trouble",
  t = { "<cmd>ToggleTerm direction=float<cr>", "Terminal Flutuante" },
  h = { "<cmd>ToggleTerm direction=horizontal size=12<cr>", "Terminal Horizontal" },
  v = { "<cmd>ToggleTerm direction=vertical size=80<cr>", "Terminal Vertical" },
  d = { "<cmd>Trouble diagnostics toggle<cr>", "Diagnósticos (Trouble)" },
  q = { "<cmd>Trouble quickfix toggle<cr>", "Quickfix (Trouble)" },
}

lvim.builtin.which_key.mappings["C"] = {
  name = "+Copilot Chat",
  c = { "<cmd>CopilotChat<cr>", "Abrir Chat" },
  q = { "<cmd>CopilotChatClose<cr>", "Fechar Chat" },
  r = { "<cmd>CopilotChatReset<cr>", "Reset Chat" },
  e = { "<cmd>CopilotChatExplain<cr>", "Explicar Código" },
  f = { "<cmd>CopilotChatFix<cr>", "Corrigir Código" },
  o = { "<cmd>CopilotChatOptimize<cr>", "Otimizar Código" },
  t = { "<cmd>CopilotChatTests<cr>", "Gerar Testes" },
}

-- ============================================================================
-- LUNARVIM BUILTINS
-- ============================================================================

-- Treesitter: guaranteed languages
lvim.builtin.treesitter.ensure_installed = {
  "lua",
  "python",
  "go", "gomod", "gosum",
  "rust",
  "typescript", "tsx", "javascript",
  "html", "css", "scss",
  "json", "jsonc", "yaml", "toml",
  "bash",
  "markdown", "markdown_inline",
  "regex",
  "dockerfile",
  "gitignore",
}
lvim.builtin.treesitter.highlight.enable = true
lvim.builtin.treesitter.indent.enable = true

-- NvimTree
lvim.builtin.nvimtree.setup.view.width = 35
lvim.builtin.nvimtree.setup.renderer.icons.show.git = true

-- Terminal
lvim.builtin.terminal.active = true
lvim.builtin.terminal.direction = "float"

-- ============================================================================
-- LSP
-- ============================================================================

-- LSP servers to auto-install/configure
vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "tsserver" })

local lsp_manager = require("lvim.lsp.manager")

-- TypeScript/JavaScript (via typescript-language-server)
lsp_manager.setup("ts_ls")

-- Python (pyright)
lsp_manager.setup("pyright", {
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
        autoImportCompletions = true,
      },
    },
  },
})

-- Go (gopls)
lsp_manager.setup("gopls", {
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
      gofumpt = true,
    },
  },
})

-- Rust (rust-analyzer)
lsp_manager.setup("rust_analyzer", {
  settings = {
    ["rust-analyzer"] = {
      checkOnSave = {
        command = "clippy",
      },
      cargo = {
        allFeatures = true,
      },
    },
  },
})

-- Lua (lua_ls)
lsp_manager.setup("lua_ls", {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim", "lvim" },
      },
    },
  },
})

-- HTML/CSS/JSON
lsp_manager.setup("html")
lsp_manager.setup("cssls")
lsp_manager.setup("jsonls")

-- Tailwind CSS (uncomment if you use it)
-- lsp_manager.setup("tailwindcss")

-- ============================================================================
-- FORMATTERS & LINTERS (via none-ls)
-- ============================================================================

local formatters = require("lvim.lsp.null-ls.formatters")
formatters.setup({
  { name = "stylua" },                                                     -- Lua
  { name = "black" },                                                      -- Python
  { name = "isort",  args = { "--profile", "black" } },                    -- Python imports
  { name = "goimports" },                                                  -- Go
  { name = "prettierd", filetypes = { "typescript", "typescriptreact",     -- Web
    "javascript", "javascriptreact", "html", "css", "json", "yaml", "markdown" } },
})

local linters = require("lvim.lsp.null-ls.linters")
linters.setup({
  { name = "eslint_d", filetypes = { "typescript", "typescriptreact",      -- Web
    "javascript", "javascriptreact" } },
  { name = "flake8",   args = { "--max-line-length", "120" } },            -- Python
  { name = "golangci_lint" },                                              -- Go
})

-- ============================================================================
-- AUTOCOMPLETION (nvim-cmp)
-- ============================================================================

-- Register Copilot as an autocomplete source
local cmp = require("cmp")
lvim.builtin.cmp.formatting.source_names["copilot"] = "(Copilot)"
lvim.builtin.cmp.sources = cmp.config.sources({
  { name = "copilot",  group_index = 1, priority = 100 },
  { name = "nvim_lsp", group_index = 1 },
  { name = "luasnip",  group_index = 1 },
  { name = "buffer",   group_index = 2 },
  { name = "path",     group_index = 2 },
})

-- ============================================================================
-- PLUGINS
-- ============================================================================

lvim.plugins = {
  -- Multi-cursor
  { "mg979/vim-visual-multi" },

  -- Markdown rendering in the editor
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
  },

  -- GitHub Copilot
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = { enabled = false },
        panel = { enabled = false },
      })
    end,
  },

  -- Copilot as nvim-cmp source
  {
    "zbirenbaum/copilot-cmp",
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
    build = "make tiktoken",
    config = function()
      require("CopilotChat").setup({
        show_help = "yes",
        question_header = "  Você ",
        answer_header = "   Copilot ",
        error_header = "  Erro ",
        highlight_selection = true,
        window = {
          layout = "vertical",
          width = 0.4,
          relative = "editor",
          side = "right",
          border = "none",
        },
      })
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

  -- Highlight TODO, FIXME, HACK, etc.
  {
    "folke/todo-comments.nvim",
    event = "BufRead",
    config = function()
      require("todo-comments").setup()
    end,
  },

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

  -- Go: extra tooling
  {
    "olexsmir/gopher.nvim",
    ft = "go",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("gopher").setup()
    end,
  },

  -- Rust: extra tooling
  {
    "simrat39/rust-tools.nvim",
    ft = "rust",
    config = function()
      require("rust-tools").setup({
        server = {
          on_attach = require("lvim.lsp").common_on_attach,
          on_init = require("lvim.lsp").common_on_init,
        },
      })
    end,
  },
}
