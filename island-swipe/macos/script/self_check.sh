#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
SELF_CHECK_BIN="$DIST_DIR/ActivityMonitorMacSelfCheck"
MODULE_CACHE="$ROOT_DIR/.build/selfcheck-module-cache"
SOURCE_FILES=()

while IFS= read -r file; do
  SOURCE_FILES+=("$file")
done < <(find "$ROOT_DIR/Sources/ActivityMonitorMac" -name '*.swift' ! -path '*/App/*' | sort)

mkdir -p "$DIST_DIR" "$MODULE_CACHE"

swiftc \
  -module-cache-path "$MODULE_CACHE" \
  "${SOURCE_FILES[@]}" \
  "$ROOT_DIR/script/self_check.swift" \
  -o "$SELF_CHECK_BIN"

"$SELF_CHECK_BIN"
