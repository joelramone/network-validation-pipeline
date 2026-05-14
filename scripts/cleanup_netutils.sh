#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

K8S_NAMESPACE="${K8S_NAMESPACE:-kube-system}"
K8S_POD_NAME="${K8S_POD_NAME:-net-utils}"

log INFO "Cleaning up ${K8S_NAMESPACE}/${K8S_POD_NAME} pod"
kubectl -n "${K8S_NAMESPACE}" delete pod "${K8S_POD_NAME}" --ignore-not-found --wait=true >/dev/null 2>&1 || true
log INFO "Cleanup finished for ${K8S_NAMESPACE}/${K8S_POD_NAME}"
