pipeline {
  agent any

  options {
    timestamps()
    ansiColor('xterm')
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '30'))
  }

  parameters {
    choice(
      name: 'ENVIRONMENT',
      choices: ['lab', 'test', 'dev', 'qa', 'prod'],
      description: 'Target environment'
    )
    booleanParam(name: 'ENABLE_PING', defaultValue: true, description: 'Enable ping checks')
    booleanParam(name: 'ENABLE_TRACEROUTE', defaultValue: false, description: 'Enable traceroute checks')
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Run network validation') {
      steps {
        sh '''#!/usr/bin/env bash
          set -euo pipefail
          source "config/environments/${ENVIRONMENT}.env"
          aws eks update-kubeconfig --region "${AWS_REGION}" --name "${EKS_CLUSTER}"
          ENABLE_PING="${ENABLE_PING}" ENABLE_TRACEROUTE="${ENABLE_TRACEROUTE}" scripts/main.sh --environment "${ENVIRONMENT}"
        '''
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: 'reports/**/*,logs/*', fingerprint: true, allowEmptyArchive: true
      publishHTML(target: [
        allowMissing: true,
        alwaysLinkToLastBuild: true,
        keepAll: true,
        reportDir: "reports/${params.ENVIRONMENT}",
        reportFiles: 'report.html',
        reportName: "Network Validation Report (${params.ENVIRONMENT})"
      ])
    }
  }
}
