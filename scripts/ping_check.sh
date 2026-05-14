#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/kubectl_exec.sh"
run_ping_check(){ local ns="$1" pod="$2" host="$3"; local out; if out="$(kubectl_exec "$ns" "$pod" "ping -c 3 -W 2 ${host}" 2>&1)"; then record_result ping "$host" PASS "$out"; log INFO "PING PASS ${host}"; else record_result ping "$host" FAIL "$out"; log ERROR "PING FAIL ${host}: ${out}"; fi; }
