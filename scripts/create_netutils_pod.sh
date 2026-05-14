#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

K8S_NAMESPACE="${K8S_NAMESPACE:-kube-system}"
K8S_POD_NAME="${K8S_POD_NAME:-net-utils}"
NETUTILS_IMAGE="${NETUTILS_IMAGE:-nicolaka/netshoot:latest}"

log INFO "Creating ${K8S_NAMESPACE}/${K8S_POD_NAME} pod"

if kubectl -n "${K8S_NAMESPACE}" get pod "${K8S_POD_NAME}" >/dev/null 2>&1; then
  log INFO "Existing ${K8S_NAMESPACE}/${K8S_POD_NAME} detected, deleting stale pod"
  kubectl -n "${K8S_NAMESPACE}" delete pod "${K8S_POD_NAME}" --ignore-not-found --wait=true
fi

kubectl apply -f - <<MANIFEST
apiVersion: v1
kind: Pod
metadata:
  name: ${K8S_POD_NAME}
  namespace: ${K8S_NAMESPACE}
  labels:
    app: net-utils
    managed-by: network-validation-pipeline
spec:
  restartPolicy: Never
  containers:
    - name: net-utils
      image: ${NETUTILS_IMAGE}
      imagePullPolicy: IfNotPresent
      command: ["sh", "-c", "sleep infinity"]
      readinessProbe:
        exec:
          command: ["sh", "-c", "command -v curl >/dev/null && command -v dig >/dev/null && command -v nc >/dev/null && command -v openssl >/dev/null"]
        initialDelaySeconds: 2
        periodSeconds: 3
        timeoutSeconds: 2
MANIFEST

log INFO "Pod manifest applied for ${K8S_NAMESPACE}/${K8S_POD_NAME}"
