# 🌙 My LunarVim Config

It is tuned for TypeScript/JavaScript, Python, Go, Rust, and Lua, with Copilot, LSP, debugging, testing, formatters, and a few plugins that make editing faster without turning the editor into a maze.

![Neovim](https://img.shields.io/badge/Neovim-0.11+-57A143?logo=neovim&logoColor=white)
![LunarVim](https://img.shields.io/badge/LunarVim-latest-blue?logo=lua&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-yellow)

## what is included

- Tokyo Night theme (`tokyonight-night`)
- GitHub Copilot (`copilot.lua`, `copilot-cmp`, `CopilotChat.nvim`)
- LSP for TS/JS, Python, Go, Rust, Lua, HTML, CSS, JSON, YAML, Bash, Docker, TOML, Markdown and Tailwind
- Debugging (`nvim-dap`) for Go, Python, Rust, JS/TS and C/C++
- Test runner (`neotest`) for Go, pytest, Jest and Vitest
- Git: gitsigns, lazygit and `diffview.nvim` for diffs and history
- Format on save, plus linters wired through `none-ls`
- Fast motion (`flash.nvim`), diagnostics view (`trouble.nvim`), TODO highlights, multi-cursor, surround edits
- File pinning (`harpoon`), per-project sessions (`persistence.nvim`), project-wide search & replace (`grug-far`)

## layout

`config.lua` is only an entrypoint. Everything else lives under `lua/user/`, which LunarVim puts on the runtimepath automatically.

| Module | Responsibility |
| --- | --- |
| `options.lua` | `vim.opt`, diagnostics, format-on-save |
| `builtins.lua` | `lvim.builtin.*` (treesitter, telescope, nvimtree, cmp, ...) |
| `plugins.lua` | `lvim.plugins` |
| `lsp.lua` | language servers |
| `formatting.lua` | none-ls formatters + linters |
| `dap.lua` | debug adapters |
| `keymaps.lua` | direct keymaps |
| `whichkey.lua` | `<leader>` menus |
| `autocmds.lua` | editor behaviour |

A module that fails to load reports itself and the rest of the config still comes up. `lua/user/local.lua` is gitignored and loaded last, so per-machine tweaks do not have to be committed.

## installation

### prerequisites

- [Neovim](https://neovim.io/) 0.11+
- [LunarVim](https://www.lunarvim.org/docs/installation)
- [Node.js](https://nodejs.org/)
- [Python 3](https://www.python.org/)
- Optional: [Go](https://go.dev/), [Rust](https://rustup.rs/), [lazygit](https://github.com/jesseduffield/lazygit)
- A [Nerd Font](https://www.nerdfonts.com/) configured in your terminal

### setup

```bash
git clone https://github.com/cleissonbarbosa/my-lvim-config.git
cd my-lvim-config
./install.sh
```

`install.sh` checks the dependencies, symlinks the repository to `~/.config/lvim` (backing up whatever is there first), then installs the plugins and Mason tools headlessly. After it finishes, just start `lvim`.

The symlink is the point: `lvim` always runs what is checked out here, and lazy.nvim writes `lazy-lock.json` straight back into the repo, so plugin updates show up as a normal diff instead of needing a copy step.

| Flag | Effect |
| --- | --- |
| `-n`, `--dry-run` | Print what would happen and exit without touching anything |
| `-f`, `--force` | Do not prompt before replacing an existing config (still backed up) |
| `--no-bootstrap` | Only link; let plugins and tools install on the first `lvim` launch |

It honours `LUNARVIM_CONFIG_DIR` if you point LunarVim somewhere other than `~/.config/lvim`, and it is safe to re-run — an existing link to this repo is left alone.

The debug adapters (`delve`, `debugpy`, `codelldb`, `js-debug-adapter`) install on the first interactive launch, and `pyright` comes from npm rather than Mason:

```bash
npm install -g pyright
```

### mason tools used in this config

| Tool | Purpose |
| --- | --- |
| `ts_ls` | TypeScript/JavaScript LSP |
| `pyright` | Python types (installed globally via npm, not Mason) |
| `ruff` | Python lint + format + import sorting (LSP) |
| `gopls` | Go LSP |
| `rust-analyzer` | Rust LSP (managed by `rustaceanvim`) |
| `lua_ls` | Lua LSP |
| `html`, `cssls`, `jsonls`, `emmet_ls`, `tailwindcss` | Web LSP |
| `yamlls`, `bashls`, `dockerls`, `taplo`, `marksman` | Config/docs LSP |
| `prettierd`, `stylua`, `goimports`, `shfmt`, `taplo` | Formatting |
| `eslint_d`, `golangci-lint`, `shellcheck`, `hadolint`, `markdownlint`, `yamllint` | Linting |
| `delve`, `debugpy`, `codelldb`, `js-debug-adapter` | Debug adapters |

Python uses `ruff` instead of black + isort + flake8: one tool, and it runs as a language server, so lint and format both come over LSP. `pyright` keeps type checking and hover; overlapping features are disabled on each side so nothing is reported twice.

## keymaps I use most

| Shortcut | Mode | Action |
| --- | --- | --- |
| `Ctrl+S` | normal/insert | Save |
| `Ctrl+↑` / `Ctrl+↓` | normal/visual | Move line or selection |
| `Alt+arrows` | normal | Resize the current split |
| `Shift+H` / `Shift+L` | normal | Previous/next buffer |
| `s` / `S` | normal/visual | Flash jump / Flash treesitter |
| `Alt+1..4` | normal | Jump to Harpoon file 1-4 |
| `Ctrl+Space` | normal/visual | Grow the treesitter selection (`BS` shrinks) |
| `Esc` | normal | Clear search highlight |
| `Esc Esc` | terminal | Leave terminal insert mode |
| `[d` / `]d` | normal | Previous/next diagnostic |
| `q` | normal | Close help, quickfix, test panels, ... |

Leader key is `Space`.

### leader groups

LunarVim's own groups (`b` buffers, `d` debug, `g` git, `l` LSP, `p` plugins, `s` search, `T` treesitter) are extended, not replaced. On top of them:

| Group | Contents |
| --- | --- |
| `Space t` | Terminals (float/horizontal/vertical) and Trouble views |
| `Space r` | Tests: run nearest/file/all, debug, watch, output panel |
| `Space m` | Harpoon: pin a file, open the menu, cycle pins |
| `Space S` | Sessions: restore for this directory, restore last |
| `Space u` | Toggles: zen mode, colors, spell, wrap, inlay hints, diagnostics |
| `Space C` | Copilot Chat: explain, fix, optimize, tests, docs, commit message |

Some entries worth remembering:

- `Space t t`: floating terminal
- `Space t d`: diagnostics (Trouble)
- `Space g g`: lazygit
- `Space g v`: open Diffview
- `Space g h`: file history
- `Space s s`: project-wide search & replace
- `Space s u`: undo history
- `Space r r`: run the test under the cursor
- `Space d t`: toggle breakpoint · `Space d c`: continue
- `Space C c`: open Copilot Chat

## notes

- Markdown is deliberately left out of format-on-save: prettier rewrites tables and list markers in ways that fight with hand-written docs. Use `Space l f` to format it on demand.
- `lazy-lock.json` is committed, so a clone reproduces the exact plugin versions. Run `:Lazy sync` and commit the file again after updating.
- This repo tracks my personal workflow, so it may change often.
- If something feels too opinionated, adjust the module under `lua/user/` and keep what works for you.

## license

[MIT](LICENSE)
