#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/kubectl_exec.sh"
run_dns_check(){ local ns="$1" pod="$2" host="$3"; if out="$(kubectl_exec "$ns" "$pod" "dig +short ${host}" 2>&1)" && [[ -n "$out" ]]; then record_result dns "$host" PASS "$out"; log INFO "DNS PASS ${host}: ${out}"; else record_result dns "$host" FAIL "$out"; log ERROR "DNS FAIL ${host}: ${out}"; fi; }
