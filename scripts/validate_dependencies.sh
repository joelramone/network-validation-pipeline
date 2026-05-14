#!/usr/bin/env bash
set -euo pipefail
req=(kubectl awk sed)
for c in "${req[@]}"; do command -v "$c" >/dev/null 2>&1 || { echo "Missing dependency: $c"; exit 1; }; done
echo "Local dependencies validated"
