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

    stage('Load environment') {
      steps {
        sh '''#!/usr/bin/env bash
          set -euo pipefail
          source "config/environments/${ENVIRONMENT}.env"
          aws eks update-kubeconfig --region "${AWS_REGION}" --name "${EKS_CLUSTER}"
        '''
      }
    }

    stage('Create net-utils pod') {
      steps {
        sh '''#!/usr/bin/env bash
          set -euo pipefail
          source "config/environments/${ENVIRONMENT}.env"
          scripts/create_netutils_pod.sh
        '''
      }
    }

    stage('Wait for net-utils') {
      steps {
        sh '''#!/usr/bin/env bash
          set -euo pipefail
          source "config/environments/${ENVIRONMENT}.env"
          scripts/wait_for_netutils.sh
        '''
      }
    }

    stage('Validate net-utils tools') {
      steps {
        sh '''#!/usr/bin/env bash
          set -euo pipefail
          source "config/environments/${ENVIRONMENT}.env"
          scripts/validate_netutils_tools.sh
        '''
      }
    }

    stage('Execute validations') {
      steps {
        sh '''#!/usr/bin/env bash
          set -euo pipefail
          source "config/environments/${ENVIRONMENT}.env"
          ENABLE_PING="${ENABLE_PING}" ENABLE_TRACEROUTE="${ENABLE_TRACEROUTE}" scripts/main.sh --environment "${ENVIRONMENT}"
        '''
      }
    }
  }

  post {
    always {
      sh '''#!/usr/bin/env bash
        set -euo pipefail
        source "config/environments/${ENVIRONMENT}.env"
        scripts/cleanup_netutils.sh
      '''
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
