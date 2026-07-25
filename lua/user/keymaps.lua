-- ============================================================================
-- KEYMAPS
-- Leader menus live in user/whichkey.lua. This file only holds direct bindings.
-- ============================================================================

local map = vim.keymap.set

-- ---------------------------------------------------------------------------
-- Moving lines
-- ---------------------------------------------------------------------------
lvim.keys.visual_mode["<C-Down>"] = ":m '>+1<CR>gv=gv"
lvim.keys.visual_mode["<C-Up>"] = ":m '<-2<CR>gv=gv"
lvim.keys.normal_mode["<C-Down>"] = ":m .+1<CR>=="
lvim.keys.normal_mode["<C-Up>"] = ":m .-2<CR>=="

-- Multi-cursor: add cursor above/below
map("n", "<C-S-Down>", "<Plug>(VM-Add-Cursor-Down)", { silent = true, remap = true })
map("n", "<C-S-Up>", "<Plug>(VM-Add-Cursor-Up)", { silent = true, remap = true })

-- ---------------------------------------------------------------------------
-- Saving
-- ---------------------------------------------------------------------------
lvim.keys.normal_mode["<C-s>"] = ":w<CR>"
lvim.keys.insert_mode["<C-s>"] = "<Esc>:w<CR>a"

-- ---------------------------------------------------------------------------
-- Buffers and windows
-- ---------------------------------------------------------------------------
lvim.keys.normal_mode["<S-h>"] = ":BufferLineCyclePrev<CR>"
lvim.keys.normal_mode["<S-l>"] = ":BufferLineCycleNext<CR>"

-- Resize with Alt+arrows (Ctrl+arrows is taken by line moving)
map("n", "<A-Up>", "<cmd>resize +2<cr>", { desc = "Aumentar altura" })
map("n", "<A-Down>", "<cmd>resize -2<cr>", { desc = "Diminuir altura" })
map("n", "<A-Left>", "<cmd>vertical resize -2<cr>", { desc = "Diminuir largura" })
map("n", "<A-Right>", "<cmd>vertical resize +2<cr>", { desc = "Aumentar largura" })

-- ---------------------------------------------------------------------------
-- Editing quality of life
-- ---------------------------------------------------------------------------

-- Keep the selection after indenting
lvim.keys.visual_mode["<"] = "<gv"
lvim.keys.visual_mode[">"] = ">gv"

-- Keep the cursor centered while scrolling and jumping between matches
map("n", "<C-d>", "<C-d>zz", { desc = "Meia página abaixo" })
map("n", "<C-u>", "<C-u>zz", { desc = "Meia página acima" })
map("n", "n", "nzzzv", { desc = "Próxima ocorrência" })
map("n", "N", "Nzzzv", { desc = "Ocorrência anterior" })

-- Join lines without moving the cursor to the end
map("n", "J", "mzJ`z", { desc = "Juntar linhas" })

-- Paste over a selection without clobbering the unnamed register
map("x", "<leader>p", [["_dP]], { desc = "Colar sem sobrescrever registro" })

-- Delete to the black hole register
map({ "n", "v" }, "<leader>D", [["_d]], { desc = "Deletar sem copiar" })

-- Escape also clears the search highlight
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Limpar destaque da busca" })

-- ---------------------------------------------------------------------------
-- Terminal
-- ---------------------------------------------------------------------------

-- Double Esc leaves terminal insert mode (single Esc still reaches the shell)
map("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Sair do modo terminal" })

-- ---------------------------------------------------------------------------
-- Diagnostics
-- ---------------------------------------------------------------------------
map("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, { desc = "Diagnóstico anterior" })
map("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, { desc = "Próximo diagnóstico" })

-- ---------------------------------------------------------------------------
-- Harpoon: jump straight to a pinned file
-- ---------------------------------------------------------------------------
for i = 1, 4 do
  map("n", "<A-" .. i .. ">", function()
    local ok, harpoon = pcall(require, "harpoon")
    if ok then
      harpoon:list():select(i)
    end
  end, { desc = "Harpoon: arquivo " .. i })
end
