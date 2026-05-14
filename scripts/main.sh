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

ENABLE_PING="${ENABLE_PING:-true}"
ENABLE_TRACEROUTE="${ENABLE_TRACEROUTE:-false}"
ENVIRONMENT=""

usage() {
  cat <<USAGE
Usage: scripts/main.sh --environment <lab|test|dev|qa|prod>
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --environment)
      ENVIRONMENT="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      fail "${EXIT_CRITICAL}" "Unknown argument: $1"
      ;;
  esac
done

[[ -n "${ENVIRONMENT}" ]] || fail "${EXIT_CRITICAL}" "--environment is required"

ENV_FILE="${REPO_ROOT}/config/environments/${ENVIRONMENT}.env"
TARGET_FILE="${REPO_ROOT}/config/targets/${ENVIRONMENT}.yaml"

[[ -f "${ENV_FILE}" ]] || fail "${EXIT_CRITICAL}" "Environment file not found: ${ENV_FILE}"
[[ -f "${TARGET_FILE}" ]] || fail "${EXIT_CRITICAL}" "Targets file not found: ${TARGET_FILE}"

set -a
source "${ENV_FILE}"
set +a

K8S_NAMESPACE="${K8S_NAMESPACE:-kube-system}"
K8S_POD_NAME="${NETUTILS_POD:-net-utils}"

init_report_paths "${ENVIRONMENT}"

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

should_run_check() {
  local list="$1"
  local check="$2"
  [[ ",${list}," == *",${check},"* ]]
}

: > "${REPORT_NDJSON}"
PARTIAL_FAILURE=0

validate_jenkins_dependencies
validate_eks_access
validate_netutils_access

total_targets="$(yq '.targets | length' "${TARGET_FILE}")"
for ((i=0; i<total_targets; i++)); do
  name="$(yq -r ".targets[${i}].name" "${TARGET_FILE}")"
  host="$(yq -r ".targets[${i}].host" "${TARGET_FILE}")"
  port="$(yq -r ".targets[${i}].port" "${TARGET_FILE}")"
  retries="$(yq -r ".targets[${i}].retries // 1" "${TARGET_FILE}")"
  checks="$(yq -r ".targets[${i}].checks // [] | join(\",\")" "${TARGET_FILE}")"
  protocol="$(yq -r ".targets[${i}].protocol // \"tcp\"" "${TARGET_FILE}")"

  [[ -n "${host}" && "${host}" != "null" ]] || continue

  if should_run_check "${checks}" dns; then
    run_and_track "dns ${host}" run_dns_check "${K8S_NAMESPACE}" "${K8S_POD_NAME}" "${host}" "${ENVIRONMENT}" "${EKS_CLUSTER}"
  fi

  if should_run_check "${checks}" tcp; then
    for ((attempt=1; attempt<=retries; attempt++)); do
      run_and_track "tcp ${host}:${port} (attempt ${attempt}/${retries})" run_tcp_check "${K8S_NAMESPACE}" "${K8S_POD_NAME}" "${host}" "${port}" "${ENVIRONMENT}" "${EKS_CLUSTER}"
    done
  fi

  if should_run_check "${checks}" tls; then
    run_and_track "tls ${host}:${port}" run_tls_check "${K8S_NAMESPACE}" "${K8S_POD_NAME}" "${host}" "${port}" "${host}" "${ENVIRONMENT}" "${EKS_CLUSTER}"
  fi

  if should_run_check "${checks}" http && [[ "${protocol}" == "https" || "${protocol}" == "http" ]]; then
    path="$(yq -r ".targets[${i}].path // \"\"" "${TARGET_FILE}")"
    insecure="$(yq -r ".targets[${i}].curl.insecure // true" "${TARGET_FILE}")"
    verbose="$(yq -r ".targets[${i}].curl.verbose // true" "${TARGET_FILE}")"
    follow_redirects="$(yq -r ".targets[${i}].curl.follow_redirects // true" "${TARGET_FILE}")"
    port_segment=":${port}"
    if [[ "${port}" == "80" && "${protocol}" == "http" ]] || [[ "${port}" == "443" && "${protocol}" == "https" ]]; then
      port_segment=""
    fi
    url="${protocol}://${host}${port_segment}${path}"
    run_and_track "http ${name}" run_http_check "${K8S_NAMESPACE}" "${K8S_POD_NAME}" "${name}" "GET" "${url}" "${insecure}" "${verbose}" "${follow_redirects}"
  fi

  if is_truthy "${ENABLE_PING}"; then
    run_and_track "ping ${host}" run_ping_check "${K8S_NAMESPACE}" "${K8S_POD_NAME}" "${host}" "${ENVIRONMENT}" "${EKS_CLUSTER}"
  fi

  if is_truthy "${ENABLE_TRACEROUTE}"; then
    run_and_track "traceroute ${host}" run_traceroute_check "${K8S_NAMESPACE}" "${K8S_POD_NAME}" "${host}" "${ENVIRONMENT}" "${EKS_CLUSTER}"
  fi
done

generate_reports "${ENVIRONMENT}"

if (( PARTIAL_FAILURE == 1 )); then
  exit "${EXIT_PARTIAL}"
fi
exit "${EXIT_OK}"
