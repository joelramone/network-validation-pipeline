#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"
generate_reports(){
  local ndjson="${REPORT_DIR}/report.ndjson" txt="${REPORT_DIR}/report.txt" json="${REPORT_DIR}/report.json" html="${REPORT_DIR}/report.html"
  : > "$txt"
  if command -v jq >/dev/null 2>&1; then jq -s '.' "$ndjson" > "$json"; jq -r '.[] | "\(.timestamp) [\(.check)] \(.target) \(.status) - \(.details)"' "$json" > "$txt"; else cp "$ndjson" "$json"; cat "$ndjson" > "$txt"; fi
  {
    echo '<html><head><title>Network Validation Report</title></head><body><h1>Network Validation Report</h1><pre>'
    sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' "$txt"
    echo '</pre></body></html>'
  } > "$html"
  log INFO "Generated reports: $txt $json $html"
}
