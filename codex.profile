profile:
  name: network-validation-shell-ops
  focus:
    - DevOps
    - SRE
    - networking
    - troubleshooting
    - shell scripting
    - Jenkins
    - EKS
  principles:
    - shell-native-first
    - operational-simplicity
    - rapid-troubleshooting-evidence
    - enterprise-compatibility
    - low-maintenance-design
  runtime:
    namespace: kube-system
    pod: net-utils
    execution_model: kubectl-exec-only
  quality:
    standards:
      - strict-mode-bash
      - modular-scripts
      - consistent-logging
      - resilient-fail-continue-checks
      - actionable-reports
