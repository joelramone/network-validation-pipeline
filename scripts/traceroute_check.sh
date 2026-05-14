#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/kubectl_exec.sh"
run_traceroute_check(){ local ns="$1" pod="$2" host="$3"; local out; if out="$(kubectl_exec "$ns" "$pod" "traceroute -n -m 10 ${host}" 2>&1)"; then record_result traceroute "$host" PASS "$out"; log INFO "TRACEROUTE PASS ${host}"; else record_result traceroute "$host" FAIL "$out"; log ERROR "TRACEROUTE FAIL ${host}: ${out}"; fi; }
