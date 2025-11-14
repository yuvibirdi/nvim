#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "--help" ]]; then
  cat <<'EOF'
Usage: install_yazi.sh [target-dir]

Downloads the latest Yazi release for Linux and installs the binaries into
~/.local/bin (or the optional target-dir you pass in).
EOF
  exit 0
fi

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "This installer only targets Linux." >&2
  exit 1
fi

ARCH=$(uname -m)
case "$ARCH" in
  x86_64|amd64)
    ASSET="yazi-x86_64-unknown-linux-gnu"
    ;;
  aarch64|arm64)
    ASSET="yazi-aarch64-unknown-linux-gnu"
    ;;
  *)
    echo "Unsupported architecture: $ARCH" >&2
    exit 1
    ;;
 esac

BIN_DIR=${1:-"${HOME}/.local/bin"}
INSTALL_ROOT="${HOME}/.local/share/yazi"
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

mkdir -p "$BIN_DIR" "$INSTALL_ROOT"
URL="https://github.com/sxyazi/yazi/releases/latest/download/${ASSET}.tar.xz"

echo "Downloading ${URL}..."
curl -fsSL "$URL" -o "$TMPDIR/yazi.tar.xz"

tar -xJf "$TMPDIR/yazi.tar.xz" -C "$TMPDIR"
EXTRACTED_DIR="$TMPDIR/${ASSET}"

install -m755 "$EXTRACTED_DIR/yazi" "$BIN_DIR/yazi"
if [[ -f "$EXTRACTED_DIR/ya" ]]; then
  install -m755 "$EXTRACTED_DIR/ya" "$BIN_DIR/ya"
fi

cp -r "$EXTRACTED_DIR"/share/yazi/* "$INSTALL_ROOT" 2>/dev/null || true

echo "Yazi installed to $BIN_DIR"
echo "Ensure $BIN_DIR is on your PATH."
