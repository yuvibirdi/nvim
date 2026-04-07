#!/usr/bin/env bash
set -euo pipefail

BIN_DIR=${1:-"${HOME}/.local/bin"}
DATA_DIR="${HOME}/.local/share/yazi"

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "This installer only targets Linux." >&2
  exit 1
fi

ARCH="$(uname -m)"
case "$ARCH" in
  x86_64|amd64)  TARGET="x86_64-unknown-linux-gnu" ;;
  aarch64|arm64) TARGET="aarch64-unknown-linux-musl" ;;
  *)
    echo "Unsupported architecture: $ARCH" >&2
    exit 1
    ;;
esac

for cmd in unzip curl; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Please install '$cmd' and rerun." >&2
    exit 1
  fi
done

LATEST_TAG=$(curl -fsSL "https://api.github.com/repos/sxyazi/yazi/releases/latest" \
  | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p')

YAZI_URL="https://github.com/sxyazi/yazi/releases/download/${LATEST_TAG}/yazi-${TARGET}.zip"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT
mkdir -p "$BIN_DIR" "$DATA_DIR"

echo "Installing Yazi ${LATEST_TAG} for ${TARGET}..."
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

echo "Yazi ${LATEST_TAG} installed to $BIN_DIR"
echo "Add 'export PATH=\"$BIN_DIR:\$PATH\"' to your shell config if needed."
