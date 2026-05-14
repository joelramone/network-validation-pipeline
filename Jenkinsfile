pipeline {
  agent any

  options {
    timestamps()
    ansiColor('xterm')
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '30'))
  }

  parameters {
    string(name: 'AWS_REGION', defaultValue: 'us-east-1', description: 'AWS region')
    string(name: 'EKS_CLUSTER', defaultValue: 'example-eks-cluster', description: 'EKS cluster name')
    string(name: 'TARGET_FILE', defaultValue: 'config/targets.yaml', description: 'Targets YAML file')
    booleanParam(name: 'ENABLE_PING', defaultValue: true, description: 'Enable ping checks')
    booleanParam(name: 'ENABLE_TRACEROUTE', defaultValue: false, description: 'Enable traceroute checks')
  }

  environment {
    K8S_NAMESPACE = 'kube-system'
    K8S_POD_NAME = 'net-utils'
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Validate Jenkins dependencies') {
      steps {
        sh 'set -euo pipefail; scripts/validate_dependencies.sh || exit $?'
      }
    }

    stage('Configure kubeconfig') {
      steps {
        sh 'set -euo pipefail; aws eks update-kubeconfig --region "${AWS_REGION}" --name "${EKS_CLUSTER}"'
      }
    }

    stage('Validate EKS access') {
      steps {
        sh 'set -euo pipefail; kubectl cluster-info; kubectl -n "${K8S_NAMESPACE}" get pod "${K8S_POD_NAME}"'
      }
    }

    stage('Execute checks from net-utils') {
      steps {
        sh 'set +e; ENABLE_PING="${ENABLE_PING}" ENABLE_TRACEROUTE="${ENABLE_TRACEROUTE}" K8S_NAMESPACE="${K8S_NAMESPACE}" K8S_POD_NAME="${K8S_POD_NAME}" scripts/main.sh "${TARGET_FILE}"; rc=$?; set -e; if [ "$rc" -eq 2 ] || [ "$rc" -eq 3 ] || [ "$rc" -eq 4 ]; then exit "$rc"; fi; exit 0'
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: 'reports/*,logs/*', fingerprint: true, allowEmptyArchive: true
      publishHTML(target: [
        allowMissing: true,
        alwaysLinkToLastBuild: true,
        keepAll: true,
        reportDir: 'reports',
        reportFiles: 'report.html',
        reportName: 'Network Validation Report'
      ])
    }
  }
}
