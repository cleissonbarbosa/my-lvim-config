-- ============================================================================
-- FORMATTERS & LINTERS (via none-ls)
--
-- Tools are installed by mason-tool-installer, see user/plugins.lua.
-- Python is intentionally absent here: ruff runs as an LSP (user/lsp.lua) and
-- provides formatting, linting and import sorting through it.
-- ============================================================================

local web_filetypes = {
  "typescript", "typescriptreact",
  "javascript", "javascriptreact",
  "vue", "svelte",
  "html", "css", "scss", "less",
  "json", "jsonc", "yaml", "markdown", "graphql",
}

local formatters = require("lvim.lsp.null-ls.formatters")
formatters.setup({
  { name = "stylua" },                                  -- Lua
  { name = "goimports" },                               -- Go
  { name = "prettierd", filetypes = web_filetypes },    -- Web
  {
    name = "shfmt",                                     -- Shell
    -- -filename is what none-ls passes by default and is how shfmt picks the
    -- dialect; overriding args replaces the list, so it has to be repeated.
    args = { "-filename", "$FILENAME", "-i", "2", "-ci", "-bn" },
    filetypes = { "sh", "bash" },
  },
  { name = "taplo", filetypes = { "toml" } },           -- TOML
})

local linters = require("lvim.lsp.null-ls.linters")
linters.setup({
  {
    name = "eslint_d",
    filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact", "vue", "svelte" },
  },
  { name = "golangci_lint" },                                    -- Go
  { name = "shellcheck",   filetypes = { "sh", "bash" } },       -- Shell
  { name = "hadolint",     filetypes = { "dockerfile" } },       -- Dockerfile
  { name = "yamllint",     filetypes = { "yaml" } },             -- YAML
  {
    name = "markdownlint",                                       -- Markdown
    filetypes = { "markdown" },
    -- MD013 (line length) is noise for prose; MD033 blocks inline HTML.
    -- --stdin must stay first: --disable is variadic and `--` closes it.
    args = { "--stdin", "--disable", "MD013", "MD033", "--" },
  },
})
