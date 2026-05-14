#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"
source "${SCRIPT_DIR}/kubectl_exec.sh"

run_ping_check() {
  local ns="$1" pod="$2" host="$3"
  local out
  if out="$(kubectl_exec "${ns}" "${pod}" "ping -c 3 -W 2 ${host}" 2>&1)"; then
    record_result ping "${host}" PASS "${out}"
  else
    record_result ping "${host}" FAIL "${out}"
  fi
}
