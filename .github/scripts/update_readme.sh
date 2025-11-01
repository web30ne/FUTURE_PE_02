#!/usr/bin/env bash
set -euo pipefail

README="README.md"
TMP="$(mktemp)"
UTC_TIME="$(date -u +"%Y-%m-%d %H:%M:%S UTC")"
NEW_BLOCK="<!--updated-start-->\\nLast updated: ${UTC_TIME}\\n<!--updated-end-->"

if [ ! -f "$README" ]; then
  echo "Error: $README not found" >&2
 exit 1
fi