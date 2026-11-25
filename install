#!/usr/bin/env bash
# Install every external dependency this Neovim config needs.
#
# Works on macOS (Homebrew) and Linux/arm64 or x86_64 (e.g. the Jetson, bb-098).
# Idempotent: already-installed tools are skipped. Re-run any time.
#
# Installs: neovim, ripgrep, fd, yazi, lazygit, ruff, zuban, clangd,
#           a C/C++ compiler + build tools, and deno (markdown preview).
#
#   ./scripts/install.sh          # install what's missing
#   FORCE=1 ./scripts/install.sh  # reinstall even if already present

set -uo pipefail  # deliberately not -e: one failure shouldn't abort the rest

OS="$(uname -s)"
ARCH="$(uname -m)"
LOCAL_BIN="${HOME}/.local/bin"
FORCE="${FORCE:-0}"
FAILED=()

mkdir -p "$LOCAL_BIN"

have()  { command -v "$1" >/dev/null 2>&1; }
skip()  { [[ "$FORCE" != "1" ]] && have "$1"; }
note()  { printf '\n\033[1;34m==>\033[0m \033[1m%s\033[0m\n' "$*"; }
ok()    { printf '  \033[1;32m✓\033[0m %s\n' "$*"; }
warn()  { printf '  \033[1;33m! %s\033[0m\n' "$*"; }
fail()  { printf '  \033[1;31m✗ %s\033[0m\n' "$*"; FAILED+=("$1"); }

# ---------------------------------------------------------------------------
# Package-manager helpers
# ---------------------------------------------------------------------------
APT_UPDATED=0
apt_install() {
  if [[ "$APT_UPDATED" == "0" ]]; then
    sudo apt-get update -y >/dev/null && APT_UPDATED=1
  fi
  sudo apt-get install -y "$@"
}

brew_install() { brew list "$1" >/dev/null 2>&1 && [[ "$FORCE" != "1" ]] && return 0; brew install "$@"; }

# pip install for the python LSPs on Linux, tolerating PEP-668 environments.
pip_user() {
  python3 -m pip install --user --upgrade "$@" 2>/dev/null \
    || python3 -m pip install --user --break-system-packages --upgrade "$@"
}

# ===========================================================================
#  macOS
# ===========================================================================
install_macos() {
  if ! have brew; then
    fail "Homebrew not found — install it from https://brew.sh then re-run."
    return 1
  fi

  note "neovim";   if skip nvim;   then ok "already installed"; else brew_install neovim   || fail neovim;   fi
  note "ripgrep";  if skip rg;     then ok "already installed"; else brew_install ripgrep  || fail ripgrep;  fi
  note "fd";       if skip fd;     then ok "already installed"; else brew_install fd       || fail fd;       fi
  note "yazi";     if skip yazi;   then ok "already installed"; else brew_install yazi     || fail yazi;     fi
  note "lazygit";  if skip lazygit;then ok "already installed"; else brew_install lazygit  || fail lazygit;  fi
  note "clangd";   if skip clangd; then ok "already installed"; else brew_install llvm     || fail clangd;   fi
  note "deno";     if skip deno;   then ok "already installed"; else brew_install deno     || fail deno;     fi

  # Python LSPs: ruff is in Homebrew; zuban is PyPI-only -> pipx.
  note "ruff"
  if skip ruff; then ok "already installed"; else brew_install ruff || fail ruff; fi

  note "zuban"
  if skip zuban; then
    ok "already installed"
  else
    have pipx || brew_install pipx
    pipx install zuban || fail zuban
  fi
}

# ===========================================================================
#  Linux (Jetson / generic)
# ===========================================================================
install_linux() {
  note "base packages (build tools, git, curl, unzip, ripgrep, fd, clangd, python)"
  apt_install build-essential git curl unzip ripgrep fd-find clangd python3-pip \
    || warn "some apt packages failed (continuing)"

  # Debian/Ubuntu ship fd as 'fdfind'; telescope looks for 'fd'.
  if ! have fd && have fdfind; then
    ln -sf "$(command -v fdfind)" "$LOCAL_BIN/fd" && ok "symlinked fd -> fdfind"
  fi
  have rg     && ok "ripgrep ready" || fail ripgrep
  have clangd && ok "clangd ready"  || fail clangd

  # ---- neovim (appimage, extracted to /opt/nvim; no FUSE required) ----
  note "neovim"
  if skip nvim; then
    ok "already installed"
  else
    case "$ARCH" in
      aarch64|arm64) IMG="nvim-linux-arm64.appimage" ;;
      x86_64|amd64)  IMG="nvim-linux-x86_64.appimage" ;;
      *) fail "neovim (unsupported arch $ARCH)"; IMG="" ;;
    esac
    if [[ -n "$IMG" ]]; then
      tmp="$(mktemp -d)"; ( cd "$tmp"
        curl -sSLO "https://github.com/neovim/neovim/releases/latest/download/${IMG}" \
          && chmod +x "$IMG" \
          && ./"$IMG" --appimage-extract >/dev/null 2>&1 \
          && sudo rm -rf /opt/nvim \
          && sudo mv squashfs-root /opt/nvim \
          && sudo ln -sf /opt/nvim/usr/bin/nvim /usr/local/bin/nvim
      ) && ok "$(nvim --version | head -1)" || fail neovim
      rm -rf "$tmp"
    fi
  fi

  # ---- yazi (github release binary) ----
  note "yazi"
  if skip yazi; then
    ok "already installed"
  else
    case "$ARCH" in
      aarch64|arm64) YZ_TARGET="aarch64-unknown-linux-musl" ;;
      x86_64|amd64)  YZ_TARGET="x86_64-unknown-linux-gnu" ;;
      *) YZ_TARGET="" ;;
    esac
    if [[ -n "$YZ_TARGET" ]]; then
      # Resolve tag via redirect (avoids api.github.com rate limits).
      YZ_TAG=$(curl -fsSLI -o /dev/null -w '%{url_effective}' \
        "https://github.com/sxyazi/yazi/releases/latest" | sed 's#.*/tag/##')
      tmp="$(mktemp -d)"; ( cd "$tmp"
        curl -fsSL -o yazi.zip \
          "https://github.com/sxyazi/yazi/releases/download/${YZ_TAG}/yazi-${YZ_TARGET}.zip" \
          && unzip -q yazi.zip \
          && d="$(find . -maxdepth 1 -type d -name 'yazi-*' | head -1)" \
          && install -m755 "$d/yazi" "$LOCAL_BIN/yazi" \
          && install -m755 "$d/ya"   "$LOCAL_BIN/ya"
      ) && ok "yazi ${YZ_TAG}" || fail yazi
      rm -rf "$tmp"
    else
      fail "yazi (unsupported arch $ARCH)"
    fi
  fi

  # ---- lazygit (github release binary) ----
  note "lazygit"
  if skip lazygit; then
    ok "already installed"
  else
    case "$ARCH" in
      aarch64|arm64) LG_ARCH="arm64" ;;
      x86_64|amd64)  LG_ARCH="x86_64" ;;
      *) LG_ARCH="" ;;
    esac
    if [[ -n "$LG_ARCH" ]]; then
      # Resolve tag via redirect (avoids api.github.com rate limits).
      LG_TAG=$(curl -fsSLI -o /dev/null -w '%{url_effective}' \
        "https://github.com/jesseduffield/lazygit/releases/latest" | sed 's#.*/tag/v##')
      tmp="$(mktemp -d)"; ( cd "$tmp"
        curl -fsSL -o lg.tar.gz \
          "https://github.com/jesseduffield/lazygit/releases/download/v${LG_TAG}/lazygit_${LG_TAG}_Linux_${LG_ARCH}.tar.gz" \
          && tar xf lg.tar.gz lazygit \
          && install -m755 lazygit "$LOCAL_BIN/lazygit"
      ) && ok "lazygit ${LG_TAG}" || fail lazygit
      rm -rf "$tmp"
    else
      fail "lazygit (unsupported arch $ARCH)"
    fi
  fi

  # ---- python LSPs ----
  note "ruff + zuban (python LSP)"
  if skip ruff && skip zuban; then
    ok "already installed"
  else
    pip_user ruff zuban && ok "ruff + zuban installed" || fail "ruff/zuban"
  fi

  # ---- deno (only needed for markdown preview build) ----
  note "deno (markdown preview)"
  if skip deno; then
    ok "already installed"
  else
    curl -fsSL https://deno.land/install.sh | DENO_INSTALL="$HOME/.deno" sh -s -- -y >/dev/null 2>&1 \
      && ln -sf "$HOME/.deno/bin/deno" "$LOCAL_BIN/deno" && ok "deno installed" \
      || warn "deno install failed (only affects :PeekOpen markdown preview)"
  fi
}

# ===========================================================================
main() {
  note "Installing Neovim config dependencies for ${OS}/${ARCH}"
  case "$OS" in
    Darwin) install_macos ;;
    Linux)  install_linux ;;
    *) echo "Unsupported OS: $OS" >&2; exit 1 ;;
  esac

  # PATH reminder
  case ":$PATH:" in
    *":$LOCAL_BIN:"*) : ;;
    *) note "Add \$HOME/.local/bin to PATH"
       echo "  bash/zsh:  export PATH=\"\$HOME/.local/bin:\$PATH\""
       echo "  fish:      fish_add_path \$HOME/.local/bin" ;;
  esac

  echo
  if [[ ${#FAILED[@]} -eq 0 ]]; then
    note "All dependencies installed ✓  —  open nvim and run :checkhealth"
  else
    note "Done, but these failed: ${FAILED[*]}"
    echo "  Re-run, or install them manually. Everything else is ready."
    exit 1
  fi
}

main "$@"
