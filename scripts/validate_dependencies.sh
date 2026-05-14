#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"
source "${SCRIPT_DIR}/kubectl_exec.sh"

K8S_NAMESPACE="${K8S_NAMESPACE:-kube-system}"
K8S_POD_NAME="${K8S_POD_NAME:-net-utils}"

validate_jenkins_dependencies() {
  local missing=0
  local deps=(bash kubectl aws jq yq)
  for cmd in "${deps[@]}"; do
    if ! command -v "${cmd}" >/dev/null 2>&1; then
      log ERROR "Missing Jenkins dependency: ${cmd}"
      missing=1
    fi
  done
  (( missing == 0 )) || return 1
  log INFO "Jenkins dependency validation passed"
}

validate_eks_access() {
  kubectl get nodes >/dev/null 2>&1 || return 1
  log INFO "EKS access validated with kubectl get nodes"
}

validate_netutils_access() {
  kubectl -n "${K8S_NAMESPACE}" get pod "${K8S_POD_NAME}" -o jsonpath='{.status.phase}' | grep -q '^Running$' || return 1
  kubectl_exec "${K8S_NAMESPACE}" "${K8S_POD_NAME}" "echo net-utils-ok" >/dev/null
  log INFO "Access to ${K8S_NAMESPACE}/${K8S_POD_NAME} validated"
}

validate_netutils_tools() {
  local missing=0
  local tools=(curl nc dig openssl ping traceroute)
  for tool in "${tools[@]}"; do
    if ! kubectl_exec "${K8S_NAMESPACE}" "${K8S_POD_NAME}" "command -v ${tool}" >/dev/null 2>&1; then
      log ERROR "Missing net-utils tool: ${tool}"
      missing=1
    fi
  done
  (( missing == 0 )) || return 1
  log INFO "Tooling inside net-utils validated"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  validate_jenkins_dependencies || fail "${EXIT_DEPENDENCY_MISSING}" "Jenkins dependencies are missing"
  validate_eks_access || fail "${EXIT_NETUTILS_UNREACHABLE}" "EKS access validation failed (kubectl get nodes)"
  validate_netutils_access || fail "${EXIT_NETUTILS_UNREACHABLE}" "net-utils pod is not accessible"
  validate_netutils_tools || fail "${EXIT_DEPENDENCY_MISSING}" "net-utils tools are incomplete"
fi
