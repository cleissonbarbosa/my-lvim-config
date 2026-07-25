#!/usr/bin/env bash
#
# Links this repository into place as the LunarVim config directory.
#
# LunarVim reads its config from $LUNARVIM_CONFIG_DIR (~/.config/lvim by
# default). Symlinking instead of copying means `lvim` always runs what is
# checked out here, and lazy.nvim writes lazy-lock.json straight back into the
# repo, so plugin updates show up as a normal diff.
#
# Usage: ./install.sh [-f] [-n] [--no-bootstrap]

set -euo pipefail

# ---------------------------------------------------------------------------
# Output helpers
# ---------------------------------------------------------------------------
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  BOLD=$'\033[1m'; RED=$'\033[31m'; GREEN=$'\033[32m'
  YELLOW=$'\033[33m'; BLUE=$'\033[34m'; RESET=$'\033[0m'
else
  BOLD=""; RED=""; GREEN=""; YELLOW=""; BLUE=""; RESET=""
fi

info()  { printf '%s==>%s %s\n' "$BLUE"   "$RESET" "$*"; }
ok()    { printf '%s  ok%s %s\n' "$GREEN"  "$RESET" "$*"; }
warn()  { printf '%swarn%s %s\n' "$YELLOW" "$RESET" "$*" >&2; }
die()   { printf '%s err%s %s\n' "$RED"    "$RESET" "$*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# Arguments
# ---------------------------------------------------------------------------
FORCE=0
DRY_RUN=0
BOOTSTRAP=1

usage() {
  cat <<'EOF'
Usage: ./install.sh [options]

Symlinks this repository to your LunarVim config directory.

Options:
  -f, --force         Do not ask for confirmation before replacing an existing
                      config directory (it is still backed up first).
  -n, --dry-run       Print what would happen and exit without changing files.
      --no-bootstrap  Skip the headless plugin/tool installation step.
  -h, --help          Show this message.

Environment:
  LUNARVIM_CONFIG_DIR  Where to link to. Defaults to ~/.config/lvim, which is
                       what the `lvim` launcher uses.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    -f|--force)      FORCE=1 ;;
    -n|--dry-run)    DRY_RUN=1 ;;
    --no-bootstrap)  BOOTSTRAP=0 ;;
    -h|--help)       usage; exit 0 ;;
    *)               usage >&2; die "unknown option: $1" ;;
  esac
  shift
done

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '     %s(dry-run)%s %s\n' "$YELLOW" "$RESET" "$*"
  else
    "$@"
  fi
}

confirm() {
  [ "$FORCE" -eq 1 ] && return 0
  [ "$DRY_RUN" -eq 1 ] && return 0
  if [ ! -t 0 ]; then
    die "cannot prompt (not a terminal). Re-run with --force to proceed."
  fi
  printf '%s?%s %s [y/N] ' "$BOLD" "$RESET" "$1"
  read -r reply
  case "$reply" in [yY]|[yY][eE][sS]) return 0 ;; *) return 1 ;; esac
}

# ---------------------------------------------------------------------------
# Locate the repository, following symlinks so the script also works when it is
# invoked through one.
# ---------------------------------------------------------------------------
source_path=${BASH_SOURCE[0]}
while [ -L "$source_path" ]; do
  source_dir=$(cd -P "$(dirname "$source_path")" && pwd)
  source_path=$(readlink "$source_path")
  [ "${source_path#/}" = "$source_path" ] && source_path="$source_dir/$source_path"
done
REPO_DIR=$(cd -P "$(dirname "$source_path")" && pwd)

# Refuse to link something that is not this config
[ -f "$REPO_DIR/config.lua" ] && [ -d "$REPO_DIR/lua/user" ] \
  || die "$REPO_DIR does not look like this config (config.lua and lua/user/ missing)."

TARGET=${LUNARVIM_CONFIG_DIR:-$HOME/.config/lvim}

info "Repository: $REPO_DIR"
info "Config dir: $TARGET"
[ "$DRY_RUN" -eq 1 ] && warn "dry run, nothing will be written"

# ---------------------------------------------------------------------------
# Dependencies
# ---------------------------------------------------------------------------
info "Checking dependencies"

command -v nvim >/dev/null 2>&1 || die "neovim not found. See https://neovim.io/"
command -v git  >/dev/null 2>&1 || die "git not found."

# Treesitter parsers, Mason downloads and Copilot all need these
command -v node >/dev/null 2>&1 \
  || die "node not found. Copilot and the web language servers need it. See https://nodejs.org/"

if ! command -v lvim >/dev/null 2>&1; then
  die "lvim not found. Install LunarVim first: https://www.lunarvim.org/docs/installation"
fi

# Neovim 0.11+: the config uses vim.diagnostic.jump and vim.lsp.inlay_hint
nvim_version=$(nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
nvim_major=${nvim_version%%.*}
nvim_minor=${nvim_version##*.}
if [ "$nvim_major" -eq 0 ] && [ "$nvim_minor" -lt 11 ]; then
  die "neovim $nvim_version found, 0.11+ required."
fi
ok "neovim $nvim_version"

for tool in go cargo lazygit rg fd; do
  if command -v "$tool" >/dev/null 2>&1; then
    ok "$tool"
  else
    warn "$tool not found (optional; some features stay inactive)"
  fi
done

# ---------------------------------------------------------------------------
# Link
# ---------------------------------------------------------------------------
info "Linking"

already_linked=0

if [ -L "$TARGET" ]; then
  # cd -P resolves the link portably; readlink -f is GNU-only
  current=$(cd -P "$TARGET" 2>/dev/null && pwd) || current=""
  if [ "$current" = "$REPO_DIR" ]; then
    ok "already linked to this repository"
    already_linked=1
  else
    warn "$TARGET is a symlink to ${current:-a broken path}"
    confirm "Replace it?" || die "aborted."
    run rm -f "$TARGET"
  fi
elif [ -e "$TARGET" ]; then
  backup="${TARGET}.bak.$(date +%Y%m%d%H%M%S)"
  warn "$TARGET already exists as a real directory"
  confirm "Move it to $backup and link this repository instead?" || die "aborted."
  run mv "$TARGET" "$backup"
  ok "backed up to $backup"
fi

if [ "$already_linked" -eq 0 ]; then
  run mkdir -p "$(dirname "$TARGET")"
  run ln -s "$REPO_DIR" "$TARGET"
  ok "$TARGET -> $REPO_DIR"
fi

if [ "$DRY_RUN" -eq 1 ]; then
  info "Dry run finished."
  exit 0
fi

# ---------------------------------------------------------------------------
# Bootstrap
# ---------------------------------------------------------------------------
if [ "$BOOTSTRAP" -eq 0 ]; then
  info "Skipping bootstrap (--no-bootstrap)."
  printf '\n%sDone.%s Start %slvim%s; plugins and tools install on first launch.\n' \
    "$BOLD" "$RESET" "$BOLD" "$RESET"
  exit 0
fi

# Output goes to a log rather than through a pipe: piping into tail would make
# the exit status that of tail, so a failing lvim would look successful.
log_file=$(mktemp -t lvim-install.XXXXXX)
trap 'rm -f "$log_file"' EXIT

headless() {
  local label=$1 command=$2 hint=$3
  info "$label"
  if lvim --headless "+$command" +qa >"$log_file" 2>&1; then
    ok "$label — done"
  else
    warn "$label reported problems ($hint inside lvim shows details):"
    tail -15 "$log_file" >&2
  fi
}

headless "Installing plugins (a few minutes on a cold start)" "Lazy! sync" ":Lazy"

# mason-tool-installer only auto-runs on VimEnter in an interactive session, so
# the sync command is what actually provisions the servers here.
headless "Installing language servers, formatters and linters" "MasonToolsInstallSync" ":Mason"

printf '\n%sDone.%s Start %slvim%s.\n' "$BOLD" "$RESET" "$BOLD" "$RESET"
printf 'Debug adapters (delve, debugpy, codelldb, js-debug) install on the first\n'
printf 'launch, and pyright comes from npm rather than Mason:\n\n'
printf '  npm install -g pyright\n\n'
printf 'Run %s:checkhealth%s if anything looks off.\n' "$BOLD" "$RESET"
