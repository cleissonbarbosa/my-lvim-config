-- ============================================================================
-- WHICH-KEY -- <leader> menus
--
-- LunarVim already defines groups for Buffers (b), Debug (d), Git (g), LSP (l),
-- LunarVim (L), Plugins (p), Search (s) and Treesitter (T). Those are extended
-- rather than replaced, so a LunarVim update keeps adding to them.
-- ============================================================================

local wk = lvim.builtin.which_key.mappings

---Merge entries into an existing group without dropping LunarVim's defaults.
---@param key string top-level leader key
---@param entries table
local function extend(key, entries)
  wk[key] = vim.tbl_deep_extend("force", wk[key] or {}, entries)
end

-- ---------------------------------------------------------------------------
-- Terminal / Trouble
-- ---------------------------------------------------------------------------
extend("t", {
  name = "+Terminal/Trouble",
  t = { "<cmd>ToggleTerm direction=float<cr>", "Terminal Flutuante" },
  h = { "<cmd>ToggleTerm direction=horizontal size=12<cr>", "Terminal Horizontal" },
  v = { "<cmd>ToggleTerm direction=vertical size=80<cr>", "Terminal Vertical" },
  d = { "<cmd>Trouble diagnostics toggle<cr>", "Diagnósticos (Trouble)" },
  D = { "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", "Diagnósticos do Buffer" },
  q = { "<cmd>Trouble qflist toggle<cr>", "Quickfix (Trouble)" },
  l = { "<cmd>Trouble loclist toggle<cr>", "Location List (Trouble)" },
  s = { "<cmd>Trouble symbols toggle focus=false<cr>", "Símbolos (Trouble)" },
})

-- ---------------------------------------------------------------------------
-- Copilot Chat
-- ---------------------------------------------------------------------------
extend("C", {
  name = "+Copilot Chat",
  c = { "<cmd>CopilotChat<cr>", "Abrir Chat" },
  q = { "<cmd>CopilotChatClose<cr>", "Fechar Chat" },
  r = { "<cmd>CopilotChatReset<cr>", "Reset Chat" },
  e = { "<cmd>CopilotChatExplain<cr>", "Explicar Código" },
  f = { "<cmd>CopilotChatFix<cr>", "Corrigir Código" },
  o = { "<cmd>CopilotChatOptimize<cr>", "Otimizar Código" },
  t = { "<cmd>CopilotChatTests<cr>", "Gerar Testes" },
  d = { "<cmd>CopilotChatDocs<cr>", "Gerar Documentação" },
  m = { "<cmd>CopilotChatCommit<cr>", "Mensagem de Commit" },
})

-- ---------------------------------------------------------------------------
-- Testing (neotest)
-- ---------------------------------------------------------------------------
extend("r", {
  name = "+Run/Test",
  r = { function() require("neotest").run.run() end, "Teste sob o cursor" },
  f = { function() require("neotest").run.run(vim.fn.expand("%")) end, "Testes do arquivo" },
  a = { function() require("neotest").run.run(vim.uv.cwd()) end, "Todos os testes" },
  l = { function() require("neotest").run.run_last() end, "Repetir último teste" },
  d = { function() require("neotest").run.run({ strategy = "dap" }) end, "Debugar teste" },
  s = { function() require("neotest").summary.toggle() end, "Painel de testes" },
  o = { function() require("neotest").output.open({ enter = true, auto_close = true }) end, "Ver saída" },
  O = { function() require("neotest").output_panel.toggle() end, "Painel de saída" },
  w = { function() require("neotest").watch.toggle(vim.fn.expand("%")) end, "Watch do arquivo" },
  x = { function() require("neotest").run.stop() end, "Parar execução" },
})

-- ---------------------------------------------------------------------------
-- Debug -- adds to LunarVim's group
-- ---------------------------------------------------------------------------
extend("d", {
  e = { function() require("dapui").eval() end, "Avaliar expressão" },
  l = { function() require("dap").run_last() end, "Rodar última sessão" },
  B = {
    function()
      require("dap").set_breakpoint(vim.fn.input("Condição do breakpoint: "))
    end,
    "Breakpoint condicional",
  },
  L = {
    function()
      require("dap").set_breakpoint(nil, nil, vim.fn.input("Mensagem do log point: "))
    end,
    "Log point",
  },
  x = { function() require("dap").clear_breakpoints() end, "Limpar breakpoints" },
})

-- ---------------------------------------------------------------------------
-- Git -- adds to LunarVim's group (which already has gg = Lazygit and the
-- gitsigns hunk bindings)
-- ---------------------------------------------------------------------------
extend("g", {
  v = { "<cmd>DiffviewOpen<cr>", "Diffview: abrir" },
  V = { "<cmd>DiffviewClose<cr>", "Diffview: fechar" },
  h = { "<cmd>DiffviewFileHistory %<cr>", "Histórico do arquivo" },
  H = { "<cmd>DiffviewFileHistory<cr>", "Histórico do branch" },
  B = { "<cmd>Gitsigns toggle_current_line_blame<cr>", "Blame inline (toggle)" },
})

-- ---------------------------------------------------------------------------
-- Search -- adds to LunarVim's group
-- ---------------------------------------------------------------------------
extend("s", {
  u = { "<cmd>Telescope undo<cr>", "Histórico de undo" },
  s = { function() require("grug-far").open() end, "Buscar e substituir" },
  w = {
    function()
      require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
    end,
    "Substituir palavra sob o cursor",
  },
  d = { "<cmd>TodoTelescope<cr>", "TODOs do projeto" },
})

-- ---------------------------------------------------------------------------
-- Harpoon
-- ---------------------------------------------------------------------------
extend("m", {
  name = "+Harpoon",
  a = { function() require("harpoon"):list():add() end, "Marcar arquivo" },
  m = {
    function()
      local harpoon = require("harpoon")
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end,
    "Menu de marcados",
  },
  n = { function() require("harpoon"):list():next() end, "Próximo marcado" },
  p = { function() require("harpoon"):list():prev() end, "Marcado anterior" },
})

-- ---------------------------------------------------------------------------
-- Sessions
-- ---------------------------------------------------------------------------
extend("S", {
  name = "+Sessão",
  s = { function() require("persistence").load() end, "Restaurar sessão do diretório" },
  l = { function() require("persistence").load({ last = true }) end, "Restaurar última sessão" },
  d = { function() require("persistence").stop() end, "Não salvar esta sessão" },
})

-- ---------------------------------------------------------------------------
-- UI toggles
-- ---------------------------------------------------------------------------
local function toggle_opt(scope, name, label)
  return function()
    scope[name] = not scope[name]:get()
    vim.notify(string.format("%s: %s", label, scope[name]:get() and "on" or "off"))
  end
end

extend("u", {
  name = "+UI/Toggles",
  z = { "<cmd>ZenMode<cr>", "Zen mode" },
  c = { "<cmd>ColorizerToggle<cr>", "Preview de cores" },
  s = { toggle_opt(vim.opt_local, "spell", "Corretor ortográfico"), "Corretor ortográfico" },
  w = { toggle_opt(vim.opt_local, "wrap", "Quebra de linha"), "Quebra de linha" },
  n = { toggle_opt(vim.opt_local, "relativenumber", "Números relativos"), "Números relativos" },
  l = { toggle_opt(vim.opt_local, "list", "Caracteres invisíveis"), "Caracteres invisíveis" },
  h = {
    function()
      local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
      vim.lsp.inlay_hint.enable(not enabled, { bufnr = 0 })
      vim.notify("Inlay hints: " .. (not enabled and "on" or "off"))
    end,
    "Inlay hints",
  },
  d = {
    function()
      local enabled = vim.diagnostic.is_enabled()
      vim.diagnostic.enable(not enabled)
      vim.notify("Diagnósticos: " .. (not enabled and "on" or "off"))
    end,
    "Diagnósticos",
  },
})
