#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
LOG_FILE="${REPO_ROOT}/logs/network_validation.log"
REPORT_DIR="${REPO_ROOT}/reports"

mkdir -p "${REPORT_DIR}" "${REPO_ROOT}/logs"

timestamp() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }

log() { local level="$1"; shift; printf '%s [%s] %s\n' "$(timestamp)" "${level}" "$*" | tee -a "${LOG_FILE}"; }

safe_name() { echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/_/g'; }

record_result() {
  local check="$1" target="$2" status="$3" details="$4"
  local line
  line="$(printf '{"timestamp":"%s","check":"%s","target":"%s","status":"%s","details":"%s"}' "$(timestamp)" "$check" "$target" "$status" "$(echo "$details" | sed 's/"/\\"/g')")"
  printf '%s\n' "$line" >> "${REPORT_DIR}/report.ndjson"
}
