profile:
  name: sre-network-troubleshooting-shell-first
  domains:
    - DevOps
    - SRE
    - networking
    - troubleshooting
    - shell scripting
    - Jenkins
    - EKS
  constraints:
    - no-python-runtime
    - checks-only-from-net-utils
    - modular-shell-scripts
    - clear-auditable-outputs
  execution:
    jenkins_role: orchestration_only
    runtime_namespace: kube-system
    runtime_pod: net-utils
  engineering:
    priorities:
      - simplicity
      - maintainability
      - operational_stability
      - fast_debugging
      - low_maintenance
