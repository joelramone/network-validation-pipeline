#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/kubectl_exec.sh"
run_tls_check(){ local ns="$1" pod="$2" host="$3" port="$4" sni="$5"; local cmd="echo | openssl s_client -servername ${sni:-$host} -connect ${host}:${port} 2>/dev/null | openssl x509 -noout -subject -issuer -dates"; local out; if out="$(kubectl_exec "$ns" "$pod" "$cmd" 2>&1)" && [[ "$out" == *"subject="* ]]; then record_result tls "${host}:${port}" PASS "$out"; log INFO "TLS PASS ${host}:${port}"; else record_result tls "${host}:${port}" FAIL "$out"; log ERROR "TLS FAIL ${host}:${port}: ${out}"; fi; }
