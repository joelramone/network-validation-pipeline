#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

K8S_NAMESPACE="${K8S_NAMESPACE:-kube-system}"
K8S_POD_NAME="${K8S_POD_NAME:-net-utils}"
NETUTILS_WAIT_TIMEOUT="${NETUTILS_WAIT_TIMEOUT:-120s}"

log INFO "Waiting for ${K8S_NAMESPACE}/${K8S_POD_NAME} phase=Running"
kubectl wait -n "${K8S_NAMESPACE}" --for=jsonpath='{.status.phase}'=Running "pod/${K8S_POD_NAME}" --timeout="${NETUTILS_WAIT_TIMEOUT}"

log INFO "Waiting for ${K8S_NAMESPACE}/${K8S_POD_NAME} condition=Ready"
kubectl wait -n "${K8S_NAMESPACE}" --for=condition=Ready "pod/${K8S_POD_NAME}" --timeout="${NETUTILS_WAIT_TIMEOUT}"

log INFO "${K8S_NAMESPACE}/${K8S_POD_NAME} is Running and Ready"
