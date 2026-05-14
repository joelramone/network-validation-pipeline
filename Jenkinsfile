pipeline {
  agent any
  options { timestamps(); ansiColor('xterm'); disableConcurrentBuilds(); buildDiscarder(logRotator(numToKeepStr: '30')) }
  parameters {
    string(name: 'AWS_REGION', defaultValue: 'us-east-1', description: 'AWS region for EKS cluster')
    string(name: 'EKS_CLUSTER', defaultValue: 'example-eks-cluster', description: 'EKS cluster name')
    string(name: 'TARGET_FILE', defaultValue: 'config/targets.yaml', description: 'Target definitions file')
    booleanParam(name: 'ENABLE_PING', defaultValue: true, description: 'Enable ICMP checks')
    booleanParam(name: 'ENABLE_TRACEROUTE', defaultValue: false, description: 'Enable traceroute checks')
  }
  environment { K8S_NAMESPACE='kube-system'; K8S_POD_NAME='net-utils' }
  stages {
    stage('Checkout') { steps { checkout scm } }
    stage('Validate Dependencies') { steps { sh 'set -euo pipefail; scripts/validate_dependencies.sh; mkdir -p reports logs' } }
    stage('Configure Kubeconfig') { steps { sh 'set -euo pipefail; aws eks update-kubeconfig --region "${AWS_REGION}" --name "${EKS_CLUSTER}"; kubectl cluster-info' } }
    stage('Validate net-utils Pod') { steps { sh 'set -euo pipefail; kubectl -n "${K8S_NAMESPACE}" wait --for=condition=Ready pod/"${K8S_POD_NAME}" --timeout=120s; kubectl -n "${K8S_NAMESPACE}" get pod "${K8S_POD_NAME}" -o wide' } }
    stage('Run Network Validation') { steps { sh 'set -euo pipefail; ENABLE_PING="${ENABLE_PING}" ENABLE_TRACEROUTE="${ENABLE_TRACEROUTE}" K8S_NAMESPACE="${K8S_NAMESPACE}" K8S_POD_NAME="${K8S_POD_NAME}" scripts/main.sh "${TARGET_FILE}"' } }
  }
  post {
    always {
      archiveArtifacts artifacts: 'reports/*,logs/*', fingerprint: true, allowEmptyArchive: true
      publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, keepAll: true, reportDir: 'reports', reportFiles: 'report.html', reportName: 'Network Validation Report'])
    }
  }
}
