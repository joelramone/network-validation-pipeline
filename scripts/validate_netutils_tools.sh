#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"
source "${SCRIPT_DIR}/kubectl_exec.sh"

K8S_NAMESPACE="${K8S_NAMESPACE:-kube-system}"
K8S_POD_NAME="${K8S_POD_NAME:-net-utils}"

tools=(curl dig nc openssl ping traceroute)

for tool in "${tools[@]}"; do
  if kubectl_exec "${K8S_NAMESPACE}" "${K8S_POD_NAME}" "command -v ${tool}" >/dev/null 2>&1; then
    log INFO "${tool} found"
  else
    fail "${EXIT_DEPENDENCY_MISSING}" "${tool} not found in ${K8S_NAMESPACE}/${K8S_POD_NAME}"
  fi
done

log INFO "All required net-utils tools are available"
