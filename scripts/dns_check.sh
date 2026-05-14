#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"
source "${SCRIPT_DIR}/kubectl_exec.sh"

run_dns_check() {
  local ns="$1" pod="$2" host="$3"
  local out
  if out="$(kubectl_exec "${ns}" "${pod}" "dig +time=3 +tries=1 +short ${host}" 2>&1)" && [[ -n "${out}" ]]; then
    record_result dns "${host}" PASS "${out}"
  else
    out="${out:-No DNS answer}"
    record_result dns "${host}" FAIL "${out}"
  fi
}
