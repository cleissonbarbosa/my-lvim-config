# 🌙 My LunarVim Config

It is tuned for TypeScript/JavaScript, Python, Go, Rust, and Lua, with Copilot, LSP, formatters, and a few plugins that make editing faster without turning the editor into a maze.

![Neovim](https://img.shields.io/badge/Neovim-0.12+-57A143?logo=neovim&logoColor=white)
![LunarVim](https://img.shields.io/badge/LunarVim-latest-blue?logo=lua&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-yellow)

## what is included

- Tokyo Night theme (`tokyonight-night`)
- GitHub Copilot (`copilot.lua`, `copilot-cmp`, `CopilotChat.nvim`)
- LSP setup for TS/JS, Python, Go, Rust, Lua, HTML, CSS, and JSON
- Format on save
- Formatter/linter setup through `none-ls`
- Fast motion (`flash.nvim`), diagnostics view (`trouble.nvim`), TODO highlights, multi-cursor, surround edits


## installation

### prerequisites

- [Neovim](https://neovim.io/) 0.12+
- [LunarVim](https://www.lunarvim.org/docs/installation)
- [Node.js](https://nodejs.org/)
- [Python 3](https://www.python.org/)
- Optional: [Go](https://go.dev/), [Rust](https://rustup.rs/)
- A [Nerd Font](https://www.nerdfonts.com/) configured in your terminal

### setup

1. Backup your current config:

   ```bash
   mv ~/.config/lvim ~/.config/lvim.bak
   ```

2. Clone this repository:

   ```bash
   git clone https://github.com/cleissonbarbosa/my-lvim-config.git ~/.config/lvim
   ```

3. Start LunarVim:

   ```bash
   lvim
   ```

4. Open Mason and install missing tools:

   ```vim
   :Mason
   ```

### mason tools used in this config

| Tool | Purpose |
| --- | --- |
| `ts_ls` | TypeScript/JavaScript LSP |
| `pyright` | Python LSP |
| `gopls` | Go LSP |
| `rust-analyzer` | Rust LSP |
| `lua_ls` | Lua LSP |
| `html`, `cssls`, `jsonls` | Web/data LSP |
| `prettierd`, `black`, `isort`, `stylua`, `goimports` | Formatting |
| `eslint_d`, `flake8`, `golangci-lint` | Linting |

## keymaps I use most

| Shortcut | Mode | Action |
| --- | --- | --- |
| `Ctrl+S` | normal/insert | Save |
| `Ctrl+↑` / `Ctrl+↓` | normal/visual | Move line or selection |
| `Shift+H` / `Shift+L` | normal | Previous/next buffer |
| `s` / `S` | normal/visual | Flash jump / Flash treesitter |

Leader key is `Space`.

Useful leader combos:

- `Space t t`: floating terminal
- `Space t h`: horizontal terminal
- `Space t v`: vertical terminal
- `Space t d`: diagnostics (Trouble)
- `Space C c`: open Copilot Chat
- `Space C e`: explain code
- `Space C f`: fix code

## notes

- This repo tracks my personal workflow, so it may change often.
- If something feels too opinionated, adjust `config.lua` and keep what works for you.

## license

[MIT](LICENSE)
