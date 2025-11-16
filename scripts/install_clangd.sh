#!/usr/bin/env bash
set -euo pipefail

CLANGD_VERSION=${CLANGD_VERSION:-"13.0.0"}
ARCHIVE_NAME="clangd-linux-${CLANGD_VERSION}.zip"
CLANGD_URL="https://github.com/clangd/clangd/releases/download/${CLANGD_VERSION}/${ARCHIVE_NAME}"
PREFIX=${1:-"${HOME}/.local"}
TARGET_DIR="${PREFIX}/clangd-${CLANGD_VERSION}"
BIN_DIR="${PREFIX}/bin"

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "This installer targets Linux only." >&2
  exit 1
fi

ARCH=$(uname -m)
if [[ "${ARCH}" != "x86_64" && "${ARCH}" != "amd64" ]]; then
  echo "clangd upstream binaries are only provided for x86_64; detected '${ARCH}'." >&2
  exit 1
fi

for dep in curl unzip; do
  if ! command -v "$dep" >/dev/null 2>&1; then
    echo "Missing dependency: $dep. Install it (e.g. sudo apt install $dep) and rerun." >&2
    exit 1
  fi
done

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

mkdir -p "${BIN_DIR}"

echo "Downloading clangd ${CLANGD_VERSION} from ${CLANGD_URL} ..."
curl -fL "${CLANGD_URL}" -o "${TMPDIR}/clangd.zip"

unzip -q "${TMPDIR}/clangd.zip" -d "${TMPDIR}"
EXTRACTED_DIR=$(find "${TMPDIR}" -maxdepth 1 -type d -name 'clangd_*' | head -n1)

if [[ -z "${EXTRACTED_DIR}" ]]; then
  echo "Failed to locate extracted clangd directory." >&2
  exit 1
fi

rm -rf "${TARGET_DIR}"
mkdir -p "${TARGET_DIR}"
cp -a "${EXTRACTED_DIR}/." "${TARGET_DIR}/"

install -m755 "${TARGET_DIR}/bin/clangd" "${BIN_DIR}/clangd"

if [[ ":${PATH}:" != *":${BIN_DIR}:"* ]]; then
  echo "Add 'export PATH=\"${BIN_DIR}:$PATH\"' to your shell config if needed." >&2
fi

echo "clangd ${CLANGD_VERSION} installed to ${TARGET_DIR}"
echo "Binary linked at ${BIN_DIR}/clangd"
