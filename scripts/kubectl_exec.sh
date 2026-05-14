#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/common.sh
source "${SCRIPT_DIR}/common.sh"

kubectl_exec() {
  local namespace="$1"
  local pod="$2"
  local command="$3"
  kubectl exec -n "${namespace}" "${pod}" -- sh -c "${command}"
}
