#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"
source "${SCRIPT_DIR}/kubectl_exec.sh"

run_http_check() {
  local ns="$1" pod="$2" target_name="$3" method="$4" url="$5" insecure="$6" verbose="$7" follow_redirects="$8"
  local curl_flags="-sS"

  if is_truthy "${insecure}"; then
    curl_flags+=" -k"
  fi
  if is_truthy "${verbose}"; then
    curl_flags+=" -v"
  fi
  if is_truthy "${follow_redirects}"; then
    curl_flags+=" -L"
  fi

  local cmd="curl ${curl_flags} -o /tmp/netval_body.txt -w 'HTTP_CODE:%{http_code}|TOTAL_TIME:%{time_total}|REDIRECTS:%{num_redirects}' -X ${method} --max-time 20 '${url}'"
  local output http_code
  output="$(kubectl_exec "${ns}" "${pod}" "${cmd}" 2>&1 || true)"
  http_code="$(printf '%s' "${output}" | sed -n 's/.*HTTP_CODE:\([0-9][0-9][0-9]\).*/\1/p' | tail -n1)"

  if [[ "${http_code}" =~ ^2[0-9][0-9]$ || "${http_code}" =~ ^3[0-9][0-9]$ ]]; then
    record_result http "${target_name}" PASS "URL=${url} FLAGS=${curl_flags} ${output}"
  else
    record_result http "${target_name}" FAIL "URL=${url} FLAGS=${curl_flags} ${output}"
  fi
}
