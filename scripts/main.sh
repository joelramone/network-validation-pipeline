#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"; source "${SCRIPT_DIR}/dns_check.sh"; source "${SCRIPT_DIR}/tcp_check.sh"; source "${SCRIPT_DIR}/http_check.sh"; source "${SCRIPT_DIR}/tls_check.sh"; source "${SCRIPT_DIR}/ping_check.sh"; source "${SCRIPT_DIR}/traceroute_check.sh"; source "${SCRIPT_DIR}/report_generator.sh"
TARGET_FILE="${1:-config/targets.yaml}"; ENABLE_PING="${ENABLE_PING:-true}"; ENABLE_TRACEROUTE="${ENABLE_TRACEROUTE:-false}"; K8S_NAMESPACE="${K8S_NAMESPACE:-kube-system}"; K8S_POD_NAME="${K8S_POD_NAME:-net-utils}"
: > "${REPORT_DIR}/report.ndjson"
mapfile -t blocks < <(awk 'BEGIN{RS="- name:";FS="\n"} NR>1{print $0}' "${REPO_ROOT}/${TARGET_FILE}")
for block in "${blocks[@]}"; do
  name="$(echo "$block" | awk 'NR==1{print $1}')"; host="$(echo "$block" | awk -F': ' '/host:/{print $2; exit}')"
  ports="$(echo "$block" | awk -F'[][]' '/ports:/{print $2; exit}')"; http_enabled="$(echo "$block" | awk '/http:/{f=1} f&&/enabled:/{print $2; exit}')"; url="$(echo "$block" | awk '/http:/{f=1} f&&/url:/{print $2; exit}' | tr -d '"')"; method="$(echo "$block" | awk '/http:/{f=1} f&&/method:/{print $2; exit}')"
  tls_enabled="$(echo "$block" | awk '/tls:/{f=1} f&&/enabled:/{print $2; exit}')"; sni="$(echo "$block" | awk '/tls:/{f=1} f&&/server_name:/{print $2; exit}' | tr -d '"')"
  run_dns_check "$K8S_NAMESPACE" "$K8S_POD_NAME" "$host" || true
  IFS=',' read -ra port_arr <<< "$ports"; for p in "${port_arr[@]}"; do p="$(echo "$p"|xargs)"; run_tcp_check "$K8S_NAMESPACE" "$K8S_POD_NAME" "$host" "$p" || true; [[ "$tls_enabled" == "true" ]] && run_tls_check "$K8S_NAMESPACE" "$K8S_POD_NAME" "$host" "$p" "$sni" || true; done
  [[ "$http_enabled" == "true" && -n "$url" ]] && run_http_check "$K8S_NAMESPACE" "$K8S_POD_NAME" "$name" "$method" "$url" || true
  [[ "$ENABLE_PING" == "true" ]] && run_ping_check "$K8S_NAMESPACE" "$K8S_POD_NAME" "$host" || true
  [[ "$ENABLE_TRACEROUTE" == "true" ]] && run_traceroute_check "$K8S_NAMESPACE" "$K8S_POD_NAME" "$host" || true
done
generate_reports
