# network-validation-pipeline

Bootstrap profesional para validación de networking post-change usando Jenkins + EKS + `kubectl exec` contra el pod `kube-system/net-utils`.

## Arquitectura

- **Jenkins (EC2):** orquesta pipeline, prepara entorno Python y publica artefactos.
- **AWS EKS:** contexto Kubernetes configurado con `aws eks update-kubeconfig`.
- **Pod ejecutor:** `kube-system/net-utils` para ejecutar pruebas de red dentro del clúster.
- **Motor Python modular:** carga targets, ejecuta checks base y genera reportes JSON/HTML.

## Flujo operativo

1. Checkout del repositorio.
2. Preparación de entorno Python e instalación de dependencias.
3. Configuración de kubeconfig para EKS.
4. Verificación de disponibilidad del pod `net-utils`.
5. Ejecución del runner `scripts/validate_network.py`.
6. Generación de reportes:
   - `reports/validation_report.json`
   - `reports/validation_report.html`
7. Publicación de artifacts en Jenkins.

## `kubectl exec` en este proyecto

Jenkins no ejecuta pruebas de networking directamente en EC2. La estrategia es invocar comandos dentro del pod `net-utils` usando:

```bash
kubectl exec -n kube-system net-utils -- sh -c "<comando>"
```

Esto permite troubleshooting desde el plano de red del clúster y reduce falsos positivos desde el host Jenkins.

## Estructura

```text
network-validation-pipeline/
├── Jenkinsfile
├── README.md
├── requirements.txt
├── .gitignore
├── agent.md
├── codex.profile.yaml
├── config/
│   └── targets.yaml
├── reports/
├── logs/
├── templates/
│   └── report_template.html
└── scripts/
    ├── __init__.py
    ├── checks.py
    ├── config_loader.py
    ├── kubectl_runner.py
    ├── logger_config.py
    ├── models.py
    ├── reporting.py
    └── validate_network.py
```

## Dependencias

- Python 3.11+
- AWS CLI v2
- kubectl
- Acceso IAM para `eks:DescribeCluster` y autenticación al clúster

Instalación local:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Ejecución local (bootstrap)

```bash
python scripts/validate_network.py \
  --targets config/targets.yaml \
  --namespace kube-system \
  --pod net-utils \
  --enable-ping true \
  --enable-traceroute false \
  --output-json reports/validation_report.json \
  --output-html reports/validation_report.html
```

## Objetivo operativo

Este bootstrap establece una base enterprise-ready, modular y configuration-driven para evolucionar por fases:

- DNS checks
- TCP checks
- HTTP/HTTPS checks
- TLS validation
- ping
- traceroute
- reportes JSON/HTML
- artifacts para Jenkins

## Comandos Git iniciales

```bash
# crear repositorio local
cd network-validation-pipeline
git init

# branch principal
git checkout -b main

# primer commit
git add .
git commit -m "chore: bootstrap network validation pipeline structure"

# conectar remoto y publicar (opcional)
git remote add origin <REPO_URL>
git push -u origin main
```
