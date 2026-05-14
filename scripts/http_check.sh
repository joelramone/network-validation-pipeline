#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/kubectl_exec.sh"
run_http_check(){ local ns="$1" pod="$2" name="$3" method="$4" url="$5"; local code; code="$(kubectl_exec "$ns" "$pod" "curl -sS -o /dev/null -w '%{http_code}' -X ${method} --max-time 10 '${url}'" 2>&1 || true)"; if [[ "$code" =~ ^2|3 ]]; then record_result http "$name" PASS "HTTP ${code} ${url}"; log INFO "HTTP PASS ${name} ${code}"; else record_result http "$name" FAIL "HTTP ${code} ${url}"; log ERROR "HTTP FAIL ${name} ${code}"; fi; }
