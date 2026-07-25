-- ============================================================================
-- DAP -- debug adapters
--
-- nvim-dap and nvim-dap-ui ship with LunarVim; the adapters are installed by
-- mason-nvim-dap (user/plugins.lua). Registration is split like this:
--
--   Go     -> nvim-dap-go
--   Python -> nvim-dap-python
--   Rust   -> rustaceanvim (`:RustLsp debuggables`)
--   JS/TS  -> registered below, js-debug has no wrapper plugin
--   C/C++  -> registered below, via the same codelldb binary Rust uses
--
-- on_config_done runs at the end of LunarVim's own dap setup, so nothing here
-- forces nvim-dap to load at startup.
-- ============================================================================

local mason = vim.fn.stdpath("data") .. "/mason"

lvim.builtin.dap.on_config_done = function(dap)
  -- -------------------------------------------------------------------------
  -- JavaScript / TypeScript (vscode-js-debug)
  -- -------------------------------------------------------------------------
  local js_debug = mason .. "/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"

  if vim.fn.filereadable(js_debug) == 1 then
    dap.adapters["pwa-node"] = {
      type = "server",
      host = "localhost",
      port = "${port}",
      executable = {
        command = "node",
        args = { js_debug, "${port}" },
      },
    }

    for _, ft in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
      dap.configurations[ft] = {
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch arquivo atual",
          program = "${file}",
          cwd = "${workspaceFolder}",
          sourceMaps = true,
          skipFiles = { "<node_internals>/**", "**/node_modules/**" },
        },
        {
          type = "pwa-node",
          request = "attach",
          name = "Attach a processo Node",
          processId = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
          sourceMaps = true,
          skipFiles = { "<node_internals>/**", "**/node_modules/**" },
        },
      }
    end
  end

  -- -------------------------------------------------------------------------
  -- C / C++ (codelldb)
  -- -------------------------------------------------------------------------
  local codelldb = mason .. "/bin/codelldb"

  if vim.fn.executable(codelldb) == 1 then
    dap.adapters.codelldb = {
      type = "server",
      port = "${port}",
      executable = {
        command = codelldb,
        args = { "--port", "${port}" },
      },
    }

    for _, ft in ipairs({ "c", "cpp" }) do
      dap.configurations[ft] = {
        {
          name = "Launch binário",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Caminho do binário: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
      }
    end
  end
end
