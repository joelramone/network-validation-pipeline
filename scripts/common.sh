#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
LOG_DIR="${REPO_ROOT}/logs"
REPORT_BASE_DIR="${REPO_ROOT}/reports"
LOG_FILE="${LOG_DIR}/network_validation.log"

readonly EXIT_OK=0
readonly EXIT_PARTIAL=1
readonly EXIT_CRITICAL=2
readonly EXIT_DEPENDENCY_MISSING=3
readonly EXIT_NETUTILS_UNREACHABLE=4

mkdir -p "${LOG_DIR}" "${REPORT_BASE_DIR}"

timestamp() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }

init_report_paths() {
  local environment="$1"
  REPORT_DIR="${REPORT_BASE_DIR}/${environment}"
  REPORT_NDJSON="${REPORT_DIR}/report.ndjson"
  mkdir -p "${REPORT_DIR}"
}

log() {
  local level="$1"
  shift
  printf '%s [%s] %s\n' "$(timestamp)" "${level}" "$*" | tee -a "${LOG_FILE}" >&2
}

fail() {
  local code="$1"
  shift
  log ERROR "$*"
  exit "${code}"
}

json_escape() {
  local raw="$1"
  raw="${raw//\\/\\\\}"
  raw="${raw//\"/\\\"}"
  raw="${raw//$'\n'/\\n}"
  raw="${raw//$'\r'/}"
  raw="${raw//$'\t'/\\t}"
  printf '%s' "${raw}"
}

record_result() {
  local check="$1" target="$2" status="$3" details="$4"
  printf '{"timestamp":"%s","check":"%s","target":"%s","status":"%s","details":"%s"}\n' \
    "$(timestamp)" "$(json_escape "${check}")" "$(json_escape "${target}")" "$(json_escape "${status}")" "$(json_escape "${details}")" \
    >> "${REPORT_NDJSON}"
}

is_truthy() {
  case "${1,,}" in
    true|1|yes|y|on) return 0 ;;
    *) return 1 ;;
  esac
}
