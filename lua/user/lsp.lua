-- ============================================================================
-- LSP
-- ============================================================================

-- Servers configured by hand below (or by another plugin) must be kept out of
-- LunarVim's automatic setup, otherwise they get attached twice.
local owned_servers = {
  "tsserver",
  "ts_ls",
  "pyright",
  "basedpyright",
  "ruff",
  "rust_analyzer", -- owned by rustaceanvim
}

vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, owned_servers)

---Drop stale entries from LunarVim's generated ftplugin cache.
---
---LunarVim writes one ftplugin per filetype into $LUNARVIM_RUNTIME_DIR and only
---refreshes them on :LvimCacheReset -- adding a server to skipped_servers does
---nothing to files that already exist. A leftover `setup("rust_analyzer")` is
---how a second rust-analyzer ends up running next to the one rustaceanvim
---starts (they attach under different client names, so LunarVim's duplicate
---check does not catch it). Pruning here keeps the config correct without
---asking for a manual cache reset after every change.
---@param servers string[]
local function prune_stale_templates(servers)
  local dir = lvim.lsp.templates_dir
  if not dir or vim.fn.isdirectory(dir) == 0 then
    return
  end

  local ok_utils, lsp_utils = pcall(require, "lvim.lsp.utils")
  if not ok_utils then
    return
  end

  -- Only the filetypes these servers claim, not the whole ~300 file cache
  local filetypes = {}
  for _, server in ipairs(servers) do
    for _, ft in ipairs(lsp_utils.get_supported_filetypes(server) or {}) do
      filetypes[ft] = true
    end
  end

  for filetype in pairs(filetypes) do
    local path = dir .. "/" .. filetype .. ".lua"
    if vim.fn.filereadable(path) == 1 then
      local kept, dropped = {}, false

      for _, line in ipairs(vim.fn.readfile(path)) do
        local stale = false
        for _, server in ipairs(servers) do
          if line:find('setup("' .. server .. '")', 1, true) then
            stale = true
          end
        end
        if stale then
          dropped = true
        else
          kept[#kept + 1] = line
        end
      end

      if dropped then
        if #kept > 0 then
          vim.fn.writefile(kept, path)
        else
          vim.fn.delete(path)
        end
      end
    end
  end
end

prune_stale_templates(owned_servers)

local manager = require("lvim.lsp.manager")
local lspconfig = require("lspconfig")
local has_schemastore, schemastore = pcall(require, "schemastore")

---Set up a language server without letting a single failure abort the module.
---lsp_manager.setup throws when Mason's registry has not been fetched yet, or
---when a server has no Mason package on this platform. Before this guard, one
---such server left every server declared after it unconfigured.
---@param server string
---@param opts table?
local function lsp_manager(server, opts)
  local ok, err = pcall(manager.setup, server, opts or {})
  if not ok then
    vim.schedule(function()
      vim.notify(
        string.format("[lsp] não foi possível configurar '%s': %s", server, err),
        vim.log.levels.WARN
      )
    end)
  end
end

-- ---------------------------------------------------------------------------
-- TypeScript / JavaScript
-- The server was renamed tsserver -> ts_ls; pick whichever this lspconfig has.
-- ---------------------------------------------------------------------------
local ts_server = "tsserver"
if pcall(require, "lspconfig.configs") and require("lspconfig.configs").ts_ls then
  ts_server = "ts_ls"
end

local ts_inlay_hints = {
  includeInlayParameterNameHints = "literal",
  includeInlayParameterNameHintsWhenArgumentMatchesName = false,
  includeInlayFunctionParameterTypeHints = true,
  includeInlayVariableTypeHints = false,
  includeInlayPropertyDeclarationTypeHints = true,
  includeInlayFunctionLikeReturnTypeHints = true,
  includeInlayEnumMemberValueHints = true,
}

lsp_manager(ts_server, {
  settings = {
    typescript = {
      inlayHints = ts_inlay_hints,
      preferences = { importModuleSpecifier = "non-relative" },
    },
    javascript = {
      inlayHints = ts_inlay_hints,
    },
  },
})

-- ---------------------------------------------------------------------------
-- Python
-- Split responsibilities: pyright does types and navigation, ruff does linting,
-- formatting and import sorting. Overlapping features are turned off on each
-- side so diagnostics are not reported twice.
-- ---------------------------------------------------------------------------
local python_lsp = lspconfig.pyright and "pyright" or (lspconfig.basedpyright and "basedpyright" or nil)
if python_lsp then
  -- Set up manually rather than through lsp_manager: pyright is usually
  -- installed globally via npm, not through Mason.
  lspconfig[python_lsp].setup({
    on_attach = require("lvim.lsp").common_on_attach,
    on_init = require("lvim.lsp").common_on_init,
    capabilities = require("lvim.lsp").common_capabilities(),
    settings = {
      python = {
        analysis = {
          typeCheckingMode = "basic",
          autoImportCompletions = true,
          diagnosticMode = "openFilesOnly",
          -- ruff owns import organisation
          disableOrganizeImports = true,
        },
      },
    },
  })
end

lsp_manager("ruff", {
  on_attach = function(client, bufnr)
    -- pyright gives better hover documentation
    client.server_capabilities.hoverProvider = false
    require("lvim.lsp").common_on_attach(client, bufnr)
  end,
})

-- ---------------------------------------------------------------------------
-- Go
-- ---------------------------------------------------------------------------
lsp_manager("gopls", {
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
        unusedwrite = true,
        nilness = true,
        shadow = true,
        useany = true,
      },
      staticcheck = true,
      gofumpt = true,
      usePlaceholders = true,
      completeUnimported = true,
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  },
})

-- ---------------------------------------------------------------------------
-- Rust
-- Handled entirely by rustaceanvim (see user/plugins.lua). Calling
-- lsp_manager.setup("rust_analyzer") here would start a second client.
-- ---------------------------------------------------------------------------

-- ---------------------------------------------------------------------------
-- Lua
-- ---------------------------------------------------------------------------
lsp_manager("lua_ls", {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim", "lvim", "reload" },
      },
      workspace = {
        checkThirdParty = false,
      },
      hint = { enable = true, arrayIndex = "Disable" },
      telemetry = { enable = false },
    },
  },
})

-- ---------------------------------------------------------------------------
-- Web
-- ---------------------------------------------------------------------------
lsp_manager("html")
lsp_manager("cssls")

lsp_manager("jsonls", {
  settings = {
    json = {
      schemas = has_schemastore and schemastore.json.schemas() or nil,
      validate = { enable = true },
    },
  },
})

-- Tailwind attaches only in projects with a tailwind config (lspconfig root_dir)
lsp_manager("tailwindcss")

-- Emmet abbreviations (type `ul>li*3` + <C-y>, in insert mode)
lsp_manager("emmet_ls", {
  filetypes = {
    "html", "css", "scss", "sass", "less",
    "javascriptreact", "typescriptreact", "svelte", "vue",
  },
})

-- ---------------------------------------------------------------------------
-- Config and docs formats
-- ---------------------------------------------------------------------------
lsp_manager("yamlls", {
  settings = {
    yaml = {
      schemaStore = {
        -- disable the built-in store so schemastore.nvim can provide it
        enable = false,
        url = "",
      },
      schemas = has_schemastore and schemastore.yaml.schemas() or nil,
      keyOrdering = false,
    },
  },
})

lsp_manager("bashls")
lsp_manager("dockerls")
lsp_manager("taplo")    -- TOML
lsp_manager("marksman") -- Markdown

-- ---------------------------------------------------------------------------
-- Compatibility shim
-- none-ls still reads vim.lsp._request_name_to_capability, which newer Neovim
-- moved into vim.lsp.protocol.
-- ---------------------------------------------------------------------------
if vim.lsp
  and vim.lsp._request_name_to_capability == nil
  and vim.lsp.protocol
  and vim.lsp.protocol._request_name_to_server_capability
then
  vim.lsp._request_name_to_capability = vim.lsp.protocol._request_name_to_server_capability
end
