#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"
source "${SCRIPT_DIR}/kubectl_exec.sh"

run_http_check() {
  local ns="$1" pod="$2" target_name="$3" method="$4" url="$5"
  local result code
  result="$(kubectl_exec "${ns}" "${pod}" "curl -sS -o /tmp/netval_body.txt -w '%{http_code}|%{time_total}' -X ${method} --max-time 12 '${url}'" 2>&1 || true)"
  code="${result%%|*}"
  if [[ "${code}" =~ ^2[0-9][0-9]$ || "${code}" =~ ^3[0-9][0-9]$ ]]; then
    record_result http "${target_name}" PASS "HTTP ${code} ${url} (${result})"
  else
    record_result http "${target_name}" FAIL "HTTP ${code} ${url} (${result})"
  fi
}
