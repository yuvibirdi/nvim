#!/usr/bin/env bash
set -euo pipefail

YAZI_URL="https://github.com/sxyazi/yazi/releases/download/v25.5.31/yazi-x86_64-unknown-linux-gnu.zip"
BIN_DIR=${1:-"${HOME}/.local/bin"}
DATA_DIR="${HOME}/.local/share/yazi"

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "This installer only targets Linux." >&2
  exit 1
fi

if [[ "$(uname -m)" != "x86_64" && "$(uname -m)" != "amd64" ]]; then
  echo "This script only supports x86_64/amd64." >&2
  exit 1
fi

if ! command -v unzip >/dev/null 2>&1; then
  echo "Please install 'unzip' (e.g. sudo apt install unzip) and rerun." >&2
  exit 1
fi

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

mkdir -p "$BIN_DIR" "$DATA_DIR"

echo "Downloading Yazi from $YAZI_URL ..."
curl -fL "$YAZI_URL" -o "$TMPDIR/yazi.zip"

unzip -q "$TMPDIR/yazi.zip" -d "$TMPDIR"
EXTRACTED_DIR=$(find "$TMPDIR" -maxdepth 1 -type d -name 'yazi-*' | head -n1)

if [[ -z "$EXTRACTED_DIR" ]]; then
  echo "Failed to locate extracted Yazi directory." >&2
  exit 1
fi

install -m755 "$EXTRACTED_DIR/yazi" "$BIN_DIR/yazi"
if [[ -f "$EXTRACTED_DIR/ya" ]]; then
  install -m755 "$EXTRACTED_DIR/ya" "$BIN_DIR/ya"
fi

if [[ -d "$EXTRACTED_DIR/share/yazi" ]]; then
  cp -a "$EXTRACTED_DIR/share/yazi/." "$DATA_DIR/"
fi

echo "Yazi installed to $BIN_DIR"
echo "Add 'export PATH=\"$BIN_DIR:\$PATH\"' to your shell config if needed."
