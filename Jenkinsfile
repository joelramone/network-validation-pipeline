pipeline {
    agent any

    options {
        timestamps()
        ansiColor('xterm')
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '30'))
    }

    parameters {
        string(name: 'AWS_REGION', defaultValue: 'us-east-1', description: 'AWS region where EKS cluster is deployed')
        string(name: 'EKS_CLUSTER', defaultValue: 'example-eks-cluster', description: 'EKS cluster name')
        string(name: 'TARGET_FILE', defaultValue: 'config/targets.yaml', description: 'Target definition file')
        booleanParam(name: 'ENABLE_PING', defaultValue: true, description: 'Enable ICMP ping checks')
        booleanParam(name: 'ENABLE_TRACEROUTE', defaultValue: false, description: 'Enable traceroute checks')
    }

    environment {
        K8S_NAMESPACE = 'kube-system'
        K8S_POD_NAME = 'net-utils'
        PYTHONUNBUFFERED = '1'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Prepare Environment') {
            steps {
                sh '''
                    set -euo pipefail
                    python3 -m venv .venv
                    . .venv/bin/activate
                    pip install --upgrade pip
                    pip install -r requirements.txt
                    mkdir -p reports logs
                '''
            }
        }

        stage('Configure Kubeconfig') {
            steps {
                sh '''
                    set -euo pipefail
                    aws eks update-kubeconfig \
                      --region "${AWS_REGION}" \
                      --name "${EKS_CLUSTER}"
                    kubectl cluster-info
                '''
            }
        }

        stage('Validate net-utils Pod') {
            steps {
                sh '''
                    set -euo pipefail
                    kubectl -n "${K8S_NAMESPACE}" get pod "${K8S_POD_NAME}" -o wide
                    kubectl -n "${K8S_NAMESPACE}" wait --for=condition=Ready pod/"${K8S_POD_NAME}" --timeout=60s
                '''
            }
        }

        stage('Run Network Validation') {
            steps {
                sh '''
                    set -euo pipefail
                    . .venv/bin/activate
                    python scripts/validate_network.py \
                      --targets "${TARGET_FILE}" \
                      --namespace "${K8S_NAMESPACE}" \
                      --pod "${K8S_POD_NAME}" \
                      --enable-ping "${ENABLE_PING}" \
                      --enable-traceroute "${ENABLE_TRACEROUTE}" \
                      --output-json reports/validation_report.json \
                      --output-html reports/validation_report.html
                '''
            }
        }

        stage('Publish Reports') {
            steps {
                archiveArtifacts artifacts: 'reports/*,logs/*', fingerprint: true, allowEmptyArchive: true
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished. Reports and logs archived as Jenkins artifacts.'
        }
    }
}
