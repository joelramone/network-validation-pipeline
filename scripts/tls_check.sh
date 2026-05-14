#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"
source "${SCRIPT_DIR}/kubectl_exec.sh"

run_tls_check() {
  local ns="$1" pod="$2" host="$3" port="$4" sni="$5"
  local server_name out cmd
  server_name="${sni:-$host}"
  cmd="echo | openssl s_client -connect ${host}:${port} -servername ${server_name} 2>/dev/null | openssl x509 -noout -subject -issuer -dates"
  if out="$(kubectl_exec "${ns}" "${pod}" "${cmd}" 2>&1)" && [[ "${out}" == *"notAfter="* ]]; then
    record_result tls "${host}:${port}" PASS "${out}"
  else
    record_result tls "${host}:${port}" FAIL "${out:-TLS handshake/cert parse failed}"
  fi
}
