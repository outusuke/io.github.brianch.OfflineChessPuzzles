#!/usr/bin/env bash
set -euo pipefail

# Usage: ./generate-cargo-sources.sh <GIT_REPO_URL> [TAG_OR_BRANCH] [OUTPUT_FILE]
#./generate-cargo-sources.sh https://github.com/brianch/offline-chess-puzzles v2.5.2 cargo-sources.json

REPO_URL="${1:?Error: Provide a Git repository URL}"
GIT_REF="${2:-main}"
OUTPUT_FILE="${3:-cargo-sources.json}"

CALLER_DIR="$(pwd)"

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

echo "--> Setting up Python virtual environment..."
python3 -m venv "$TMP_DIR/venv"
"$TMP_DIR/venv/bin/pip" install -q --disable-pip-version-check aiohttp tomlkit toml

echo "--> Cloning $REPO_URL ($GIT_REF)..."
git clone --depth 1 --branch "$GIT_REF" "$REPO_URL" "$TMP_DIR/repo" 2>/dev/null || {
  git clone "$REPO_URL" "$TMP_DIR/repo"
  git -C "$TMP_DIR/repo" checkout "$GIT_REF"
}

cd "$TMP_DIR/repo"

if [ ! -f "Cargo.lock" ]; then
  echo "--> Cargo.lock missing. Generating..."
  cargo generate-lockfile
fi

echo "--> Exporting the Cargo.lock used for source generation..."
cp Cargo.lock "$CALLER_DIR/Cargo.lock"

echo "--> Downloading flatpak-cargo-generator.py..."
curl -sSL -o "$TMP_DIR/flatpak-cargo-generator.py" \
  https://raw.githubusercontent.com/flatpak/flatpak-builder-tools/master/cargo/flatpak-cargo-generator.py

echo "--> Generating cargo sources..."
"$TMP_DIR/venv/bin/python" "$TMP_DIR/flatpak-cargo-generator.py" Cargo.lock -o "$TMP_DIR/$OUTPUT_FILE"

cd - >/dev/null
mv "$TMP_DIR/$OUTPUT_FILE" "./$OUTPUT_FILE"

echo "--> Successfully generated ./${OUTPUT_FILE}"
echo "--> Successfully exported ./Cargo.lock"
