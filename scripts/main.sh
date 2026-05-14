#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"
source "${SCRIPT_DIR}/dns_check.sh"
source "${SCRIPT_DIR}/tcp_check.sh"
source "${SCRIPT_DIR}/http_check.sh"
source "${SCRIPT_DIR}/tls_check.sh"
source "${SCRIPT_DIR}/ping_check.sh"
source "${SCRIPT_DIR}/traceroute_check.sh"
source "${SCRIPT_DIR}/validate_dependencies.sh"
source "${SCRIPT_DIR}/report_generator.sh"

TARGET_FILE="${1:-config/targets.yaml}"
ENABLE_PING="${ENABLE_PING:-true}"
ENABLE_TRACEROUTE="${ENABLE_TRACEROUTE:-false}"
K8S_NAMESPACE="${K8S_NAMESPACE:-kube-system}"
K8S_POD_NAME="${K8S_POD_NAME:-net-utils}"

run_and_track() {
  local label="$1"
  shift
  if "$@"; then
    log INFO "${label}: PASS"
  else
    PARTIAL_FAILURE=1
    log ERROR "${label}: FAIL"
  fi
}

parse_targets() {
  awk '
    /^  - name:/ {if (name!="") {print name"|"host"|"ports"|"http_enabled"|"http_url"|"http_method"|"tls_enabled"|"tls_sni};
                  name=$3;host="";ports="";http_enabled="false";http_url="";http_method="GET";tls_enabled="false";tls_sni="";ctx="";next}
    /^    host:/ {host=$2;next}
    /^    ports:/ {gsub(/\[|\]|,/,"",$0);sub(/^    ports: /,"",$0);gsub(/ +/,",",$0);ports=$0;next}
    /^    http:/ {ctx="http";next}
    /^    tls:/ {ctx="tls";next}
    /^      enabled:/ && ctx=="http" {http_enabled=$2;next}
    /^      url:/ && ctx=="http" {sub(/^      url: /,"");gsub(/"/,"");http_url=$0;next}
    /^      method:/ && ctx=="http" {http_method=$2;next}
    /^      enabled:/ && ctx=="tls" {tls_enabled=$2;next}
    /^      server_name:/ && ctx=="tls" {sub(/^      server_name: /,"");gsub(/"/,"");tls_sni=$0;next}
    END {if (name!="") print name"|"host"|"ports"|"http_enabled"|"http_url"|"http_method"|"tls_enabled"|"tls_sni}
  ' "${REPO_ROOT}/${TARGET_FILE}"
}

: > "${REPORT_DIR}/report.ndjson"
PARTIAL_FAILURE=0
validate_jenkins_dependencies
validate_netutils_access
validate_netutils_tools

while IFS='|' read -r name host ports http_enabled url method tls_enabled sni; do
  [[ -z "${host}" ]] && continue
  run_and_track "dns ${host}" run_dns_check "${K8S_NAMESPACE}" "${K8S_POD_NAME}" "${host}"
  IFS=',' read -r -a port_arr <<< "${ports}"
  for port in "${port_arr[@]}"; do
    [[ -z "${port}" ]] && continue
    run_and_track "tcp ${host}:${port}" run_tcp_check "${K8S_NAMESPACE}" "${K8S_POD_NAME}" "${host}" "${port}"
    if [[ "${tls_enabled}" == "true" ]]; then
      run_and_track "tls ${host}:${port}" run_tls_check "${K8S_NAMESPACE}" "${K8S_POD_NAME}" "${host}" "${port}" "${sni}"
    fi
  done
  if [[ "${http_enabled}" == "true" && -n "${url}" ]]; then
    run_and_track "http ${name}" run_http_check "${K8S_NAMESPACE}" "${K8S_POD_NAME}" "${name}" "${method}" "${url}"
  fi
  if is_truthy "${ENABLE_PING}"; then
    run_and_track "ping ${host}" run_ping_check "${K8S_NAMESPACE}" "${K8S_POD_NAME}" "${host}"
  fi
  if is_truthy "${ENABLE_TRACEROUTE}"; then
    run_and_track "traceroute ${host}" run_traceroute_check "${K8S_NAMESPACE}" "${K8S_POD_NAME}" "${host}"
  fi
done < <(parse_targets)

generate_reports

if (( PARTIAL_FAILURE == 1 )); then
  exit "${EXIT_PARTIAL}"
fi
exit "${EXIT_OK}"
