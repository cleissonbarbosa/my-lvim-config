-- ============================================================================
-- BUILTINS -- LunarVim's bundled plugins (lvim.builtin.*)
-- ============================================================================

-- ---------------------------------------------------------------------------
-- Treesitter
-- ---------------------------------------------------------------------------
local ok_install, ts_install = pcall(require, "nvim-treesitter.install")
if ok_install then
  ts_install.prefer_git = true
end

lvim.builtin.treesitter.ensure_installed = {
  "lua", "luadoc",
  "python",
  "go", "gomod", "gosum", "gowork",
  "rust",
  "typescript", "tsx", "javascript", "jsdoc",
  "html", "css", "scss",
  "json", "jsonc", "yaml", "toml",
  "bash",
  "markdown", "markdown_inline",
  "regex",
  "sql",
  "dockerfile",
  "gitignore", "gitcommit", "git_rebase", "git_config",
  "diff",
  "make",
  "vim", "vimdoc", "query",
}

lvim.builtin.treesitter.highlight.enable = true

-- Treesitter indent misbehaves badly on Python and YAML; the built-in
-- indentexpr is more reliable there.
lvim.builtin.treesitter.indent = {
  enable = true,
  disable = { "python", "yaml" },
}

-- Expand/shrink the selection along the syntax tree
lvim.builtin.treesitter.incremental_selection = {
  enable = true,
  keymaps = {
    init_selection = "<C-Space>",
    node_incremental = "<C-Space>",
    scope_incremental = false,
    node_decremental = "<BS>",
  },
}

-- ---------------------------------------------------------------------------
-- NvimTree
-- ---------------------------------------------------------------------------
lvim.builtin.nvimtree.setup.view.width = 35
lvim.builtin.nvimtree.setup.hijack_cursor = true
lvim.builtin.nvimtree.setup.renderer.icons.show.git = true
lvim.builtin.nvimtree.setup.renderer.highlight_git = "name"
lvim.builtin.nvimtree.setup.diagnostics.show_on_dirs = true
lvim.builtin.nvimtree.setup.filters.custom = {
  "^%.git$", "node_modules", "__pycache__", "%.pytest_cache", "%.mypy_cache", "%.ruff_cache",
}

-- ---------------------------------------------------------------------------
-- Telescope
-- ---------------------------------------------------------------------------
lvim.builtin.telescope.defaults.path_display = { "truncate" }
lvim.builtin.telescope.defaults.file_ignore_patterns = {
  "^%.git/", "node_modules/", "%.lock$", "__pycache__/", "^target/", "^dist/", "^build/",
}

lvim.builtin.telescope.on_config_done = function(telescope)
  -- telescope-undo registers itself lazily; ignore it when not installed yet
  pcall(telescope.load_extension, "undo")
end

-- ---------------------------------------------------------------------------
-- Terminal
-- ---------------------------------------------------------------------------
lvim.builtin.terminal.active = true
lvim.builtin.terminal.direction = "float"
lvim.builtin.terminal.float_opts.border = "rounded"

-- ---------------------------------------------------------------------------
-- Which-Key
-- Presets are disabled where they shadow plugin mappings.
-- ---------------------------------------------------------------------------
lvim.builtin.which_key.setup.plugins = {
  marks = true,
  registers = true,
  spelling = { enabled = true, suggestions = 20 },
  presets = {
    operators = false,   -- avoid conflict with 'y' (nvim-surround) and 'g' (comment)
    motions = false,
    text_objects = false,
    windows = true,
    nav = true,
    z = true,
    g = false,           -- avoid conflict with comment.nvim 'gc'/'gb'
  },
}

-- ---------------------------------------------------------------------------
-- Completion (nvim-cmp)
-- ---------------------------------------------------------------------------
local cmp = require("cmp")

lvim.builtin.cmp.formatting.source_names["copilot"] = "(Copilot)"
lvim.builtin.cmp.experimental.ghost_text = true

lvim.builtin.cmp.sources = cmp.config.sources({
  { name = "copilot",  group_index = 1, priority = 100 },
  { name = "nvim_lsp", group_index = 1 },
  { name = "luasnip",  group_index = 1 },
  { name = "buffer",   group_index = 2 },
  { name = "path",     group_index = 2 },
})

-- ---------------------------------------------------------------------------
-- Debugger -- adapters live in user/dap.lua
-- ---------------------------------------------------------------------------
lvim.builtin.dap.active = true
