-- ============================================================================
-- OPTIONS -- editor behaviour, diagnostics presentation, format on save
-- ============================================================================

local opt = vim.opt

-- Colorscheme
lvim.colorscheme = "tokyonight-night"

-- ---------------------------------------------------------------------------
-- Appearance
-- ---------------------------------------------------------------------------
opt.relativenumber = true                                    -- Relative line numbers
opt.cursorline = true                                        -- Highlight current line
opt.termguicolors = true                                     -- Enable true colors
opt.signcolumn = "yes"                                       -- Always reserve the gutter, text never shifts
opt.wrap = false                                             -- Disable line wrapping
opt.linebreak = true                                         -- When wrap is on (per filetype), break at words
opt.scrolloff = 8                                            -- Keep 8 lines visible above/below cursor
opt.sidescrolloff = 8                                        -- Keep 8 columns visible horizontally
opt.pumheight = 12                                           -- Cap the completion popup height
opt.list = true                                              -- Show invisible characters
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣", extends = "›", precedes = "‹" }
opt.fillchars:append({ eob = " " })                          -- Hide the '~' on empty lines

-- ---------------------------------------------------------------------------
-- Indentation
-- ---------------------------------------------------------------------------
opt.shiftwidth = 2                                           -- Indentation width
opt.tabstop = 2                                              -- Tab width
opt.expandtab = true                                         -- Convert tabs to spaces
opt.shiftround = true                                        -- Round indent to a multiple of shiftwidth

-- ---------------------------------------------------------------------------
-- Search
-- ---------------------------------------------------------------------------
opt.ignorecase = true                                        -- Case-insensitive search
opt.smartcase = true                                         -- Case-sensitive when uppercase is used
opt.inccommand = "split"                                     -- Live preview for :s/foo/bar

-- ---------------------------------------------------------------------------
-- Splits
-- ---------------------------------------------------------------------------
opt.splitbelow = true                                        -- Horizontal splits open below
opt.splitright = true                                        -- Vertical splits open to the right
opt.splitkeep = "screen"                                     -- Don't scroll the text when splits open/close

-- ---------------------------------------------------------------------------
-- Files and history
-- ---------------------------------------------------------------------------
opt.undofile = true                                          -- Persistent undo history
opt.undolevels = 10000                                       -- Deep undo stack
opt.swapfile = false                                         -- Undofile + git already cover recovery
opt.confirm = true                                           -- Prompt instead of failing on unsaved buffers
opt.clipboard = "unnamedplus"                                -- Use system clipboard

-- What persistence.nvim stores per project (it reads sessionoptions)
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "folds", "skiprtp" }

-- ---------------------------------------------------------------------------
-- Responsiveness
-- ---------------------------------------------------------------------------
opt.timeoutlen = 300                                         -- Key sequence timeout (ms)
opt.updatetime = 250                                         -- Faster CursorHold (gitsigns blame, illuminate)
opt.virtualedit = "block"                                    -- Block selection can go past end of line

-- ---------------------------------------------------------------------------
-- Spell checking -- enabled per filetype in user/autocmds.lua
-- pt_br is only added when the dictionary is already present, otherwise
-- Neovim prompts to download it every time a markdown file is opened.
-- ---------------------------------------------------------------------------
local spelllang = { "en_us" }
if vim.fn.globpath(vim.o.runtimepath, "spell/pt*.spl") ~= "" then
  table.insert(spelllang, "pt_br")
end
opt.spelllang = spelllang

-- ---------------------------------------------------------------------------
-- Diagnostics
-- LunarVim applies its own vim.diagnostic.config() before config.lua runs,
-- so this replaces it wholesale.
-- ---------------------------------------------------------------------------
local icons = lvim.icons.diagnostics

vim.diagnostic.config({
  severity_sort = true,
  underline = true,
  update_in_insert = false,
  virtual_text = {
    spacing = 4,
    prefix = "●",
    source = "if_many",
  },
  float = {
    focusable = true,
    style = "minimal",
    border = "rounded",
    source = "if_many",
    header = "",
    prefix = "",
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = icons.Error,
      [vim.diagnostic.severity.WARN] = icons.Warning,
      [vim.diagnostic.severity.HINT] = icons.Hint,
      [vim.diagnostic.severity.INFO] = icons.Information,
    },
  },
})

-- Rounded borders on hover and signature help popups
lvim.lsp.float = vim.tbl_deep_extend("force", lvim.lsp.float or {}, { border = "rounded" })

-- ---------------------------------------------------------------------------
-- Format on save
-- Markdown is deliberately left out: prettier rewrites tables and list markers
-- in ways that fight with hand-written docs. Use <leader>lf to format it.
-- ---------------------------------------------------------------------------
lvim.format_on_save.enabled = true
lvim.format_on_save.timeout = 3000
lvim.format_on_save.pattern = {
  "*.lua",
  "*.py",
  "*.go",
  "*.rs",
  "*.ts", "*.tsx", "*.js", "*.jsx",
  "*.html", "*.css", "*.scss",
  "*.json", "*.jsonc",
  "*.yaml", "*.yml",
  "*.toml",
  "*.sh", "*.bash",
}
