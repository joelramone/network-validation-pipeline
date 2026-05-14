#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"
source "${SCRIPT_DIR}/kubectl_exec.sh"

run_traceroute_check() {
  local ns="$1" pod="$2" host="$3"
  local out
  if out="$(kubectl_exec "${ns}" "${pod}" "traceroute -n -m 8 -w 2 ${host}" 2>&1)"; then
    record_result traceroute "${host}" PASS "${out}"
  else
    record_result traceroute "${host}" FAIL "${out}"
  fi
}
