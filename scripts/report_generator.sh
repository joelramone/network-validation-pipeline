#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

generate_reports() {
  local ndjson="${REPORT_DIR}/report.ndjson"
  local txt="${REPORT_DIR}/report.txt"
  local json="${REPORT_DIR}/report.json"
  local html="${REPORT_DIR}/report.html"

  if command -v jq >/dev/null 2>&1; then
    jq -s '.' "${ndjson}" > "${json}"
    jq -r '.[] | "\(.timestamp) [\(.check)] \(.target) \(.status) - \(.details)"' "${json}" > "${txt}"
  else
    cp "${ndjson}" "${json}"
    cat "${ndjson}" > "${txt}"
  fi

  local template="${REPO_ROOT}/templates/report_template.html"
  local body
  body="$(sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' "${txt}")"
  sed "s|__REPORT_CONTENT__|${body//$'\n'/\\n}|g" "${template}" > "${html}"

  log INFO "Reports generated: ${txt}, ${json}, ${html}"
}
