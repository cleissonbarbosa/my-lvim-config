-- ============================================================================
-- AUTOCMDS
-- Everything lives in one augroup so `:LvimReload` replaces instead of stacking.
-- ============================================================================

local group = vim.api.nvim_create_augroup("UserConfig", { clear = true })

local function autocmd(event, opts)
  opts.group = group
  vim.api.nvim_create_autocmd(event, opts)
end

-- ---------------------------------------------------------------------------
-- Briefly highlight the text that was just yanked
-- ---------------------------------------------------------------------------
autocmd("TextYankPost", {
  desc = "Destacar texto copiado",
  callback = function()
    vim.hl.on_yank({ higroup = "Visual", timeout = 150 })
  end,
})

-- ---------------------------------------------------------------------------
-- Reopen a file where you left it
-- ---------------------------------------------------------------------------
autocmd("BufReadPost", {
  desc = "Restaurar posição do cursor",
  callback = function(args)
    local exclude = { "gitcommit", "gitrebase", "commit" }
    if vim.tbl_contains(exclude, vim.bo[args.buf].filetype) then
      return
    end

    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- ---------------------------------------------------------------------------
-- Create missing parent directories when saving a new file
-- ---------------------------------------------------------------------------
autocmd("BufWritePre", {
  desc = "Criar diretórios que faltam ao salvar",
  callback = function(args)
    if args.match:match("^%w%w+://") then -- skip oil://, fugitive:// and friends
      return
    end
    local file = vim.uv.fs_realpath(args.match) or args.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- ---------------------------------------------------------------------------
-- Strip trailing whitespace. Markdown is excluded: two trailing spaces are a
-- hard line break there.
-- ---------------------------------------------------------------------------
autocmd("BufWritePre", {
  desc = "Remover espaços no fim das linhas",
  callback = function()
    if vim.bo.filetype == "markdown" or vim.bo.binary then
      return
    end
    local view = vim.fn.winsaveview()
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
})

-- ---------------------------------------------------------------------------
-- Close throwaway windows with a single `q`
-- ---------------------------------------------------------------------------
autocmd("FileType", {
  desc = "Fechar janelas auxiliares com q",
  pattern = {
    "help", "man", "qf", "lspinfo", "startuptime", "checkhealth",
    "notify", "query", "spectre_panel", "neotest-output", "neotest-summary",
    "neotest-output-panel", "dap-float",
  },
  callback = function(args)
    vim.bo[args.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = args.buf, silent = true })
  end,
})

-- ---------------------------------------------------------------------------
-- Prose settings for text-ish filetypes
-- ---------------------------------------------------------------------------
autocmd("FileType", {
  desc = "Wrap e corretor ortográfico em textos",
  pattern = { "markdown", "gitcommit", "text" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- ---------------------------------------------------------------------------
-- Absolute line numbers where relative ones only add noise
-- ---------------------------------------------------------------------------
autocmd({ "InsertEnter", "TermOpen" }, {
  desc = "Números absolutos ao editar/no terminal",
  callback = function()
    if vim.bo.buftype == "terminal" then
      vim.opt_local.number = false
    end
    vim.opt_local.relativenumber = false
  end,
})

autocmd("InsertLeave", {
  desc = "Voltar aos números relativos",
  callback = function()
    if vim.bo.buftype ~= "terminal" then
      vim.opt_local.relativenumber = true
    end
  end,
})

-- ---------------------------------------------------------------------------
-- Keep splits proportional when the terminal is resized
-- ---------------------------------------------------------------------------
autocmd("VimResized", {
  desc = "Reequilibrar splits",
  callback = function()
    local tab = vim.api.nvim_get_current_tabpage()
    vim.cmd("tabdo wincmd =")
    vim.api.nvim_set_current_tabpage(tab)
  end,
})

-- ---------------------------------------------------------------------------
-- Pick up changes made outside the editor (git checkout, formatters, ...)
-- ---------------------------------------------------------------------------
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  desc = "Recarregar arquivos alterados fora do editor",
  command = "checktime",
})
