#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

kubectl_exec() {
  local namespace="$1" pod="$2" cmd="$3"
  kubectl exec -n "${namespace}" "${pod}" -- sh -c "${cmd}"
}
