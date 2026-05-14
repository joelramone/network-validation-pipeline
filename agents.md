# Project Agent Rules

## Objective
Shell/Bash-first network troubleshooting pipeline for Jenkins + EKS with fast evidence collection for Networking and SecOps.

## Architecture Rules
- Run every network check from `kube-system/net-utils` via `kubectl exec`.
- Keep checks modular in `scripts/` with one responsibility per file.
- Persist outputs in `reports/` and `logs/`.
- Maintain `future/python/` reserved for future analytics without affecting current shell-native runtime.

## Coding Conventions
- Every shell script must start with `#!/usr/bin/env bash` and `set -euo pipefail`.
- Use shared logging and result recording from `scripts/common.sh`.
- Keep functions composable and reusable.
- Continue execution even when individual checks fail.
- No pseudocode; only runnable scripts.

## Operational Restrictions
- Do not run network checks from Jenkins host itself.
- Avoid unnecessary dependencies and avoid Python runtime requirements.
- Prioritize clear logs and deterministic output for incident troubleshooting windows.

## Best Practices
- Validate dependencies early.
- Use deterministic report artifacts (`report.txt`, `report.json`, `report.html`).
- Keep Jenkins stages explicit and auditable.
- Prefer simple tooling (`kubectl`, `curl`, `nc`, `dig`, `openssl`, optional `jq`).
