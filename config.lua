-- Read the docs: https://www.lunarvim.org/docs/configuration
--
-- This file is only an entrypoint. Every concern lives in its own module under
-- `lua/user/`, which LunarVim puts on the runtimepath automatically.
--
--   options    -> vim.opt, diagnostics, format-on-save
--   builtins   -> lvim.builtin.* (treesitter, telescope, nvimtree, cmp, ...)
--   plugins    -> lvim.plugins
--   lsp        -> language servers
--   formatting -> none-ls formatters + linters
--   dap        -> debug adapters
--   keymaps    -> raw keymaps
--   whichkey   -> <leader> menus
--   autocmds   -> editor behaviour
--
-- Load order matters: options and builtins before plugins, keymaps after
-- everything they might reference.

local modules = {
  "options",
  "builtins",
  "plugins",
  "lsp",
  "formatting",
  "dap",
  "keymaps",
  "whichkey",
  "autocmds",
}

-- A broken module should degrade the config, not take the whole editor down.
for _, name in ipairs(modules) do
  local ok, err = pcall(require, "user." .. name)
  if not ok then
    vim.schedule(function()
      vim.notify(
        string.format("[config] falha ao carregar 'user.%s':\n%s", name, err),
        vim.log.levels.ERROR
      )
    end)
  end
end

-- Optional per-machine overrides. `lua/user/local.lua` is gitignored, so it is
-- the place for anything that should not follow the repo to another machine.
pcall(require, "user.local")
