#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

generate_reports() {
  local environment="$1"
  local ndjson="${REPORT_NDJSON}"
  local txt="${REPORT_DIR}/report.txt"
  local json="${REPORT_DIR}/report.json"
  local html="${REPORT_DIR}/report.html"

  jq -s --arg environment "${environment}" --arg cluster "${EKS_CLUSTER:-unknown}" --arg namespace "${K8S_NAMESPACE:-unknown}" \
    '{environment:$environment,cluster:$cluster,namespace:$namespace,generated_at:now|todate,results:.}' "${ndjson}" > "${json}"

  jq -r '.results[] | "\(.timestamp) env=\(.environment // \"'"${environment}"'\") cluster='"${EKS_CLUSTER:-unknown}"' ns='"${K8S_NAMESPACE:-unknown}"' [\(.check)] \(.target) \(.status) - \(.details)"' "${json}" > "${txt}"

  local template="${REPO_ROOT}/templates/report_template.html"
  local body
  body="$(sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' "${txt}")"
  sed "s|__REPORT_CONTENT__|${body//$'\n'/\\n}|g" "${template}" > "${html}"

  log INFO "Reports generated in ${REPORT_DIR}"
}
