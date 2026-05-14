#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/kubectl_exec.sh"
run_tcp_check(){ local ns="$1" pod="$2" host="$3" port="$4"; local out; if out="$(kubectl_exec "$ns" "$pod" "nc -zvw3 ${host} ${port}" 2>&1)"; then record_result tcp "${host}:${port}" PASS "$out"; log INFO "TCP PASS ${host}:${port}"; else record_result tcp "${host}:${port}" FAIL "$out"; log ERROR "TCP FAIL ${host}:${port}: ${out}"; fi; }
