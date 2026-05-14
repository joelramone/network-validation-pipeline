# network-validation-pipeline

Shell/Bash-first pipeline para troubleshooting de networking en Jenkins + EKS.

## Arquitectura operacional

```text
Jenkins EC2
  -> kubectl exec
    -> kube-system/net-utils
      -> target
```

Jenkins solo orquesta, recolecta reportes y publica evidencia. Todos los checks de red reales se ejecutan dentro del pod `kube-system/net-utils`.

## Estructura

```text
network-validation-pipeline/
├── Jenkinsfile
├── README.md
├── agents.md
├── codex.profile
├── .gitignore
├── config/targets.yaml
├── scripts/
├── reports/
├── logs/
├── templates/report_template.html
└── future/python/
```

## Dependencias por capa

### Jenkins EC2
- bash
- awscli
- kubectl
- jq

### Pod `kube-system/net-utils`
- curl
- nc
- dig
- openssl
- ping
- traceroute

## Flujo operativo

1. Checkout.
2. Validación de dependencias Jenkins y `net-utils`.
3. `aws eks update-kubeconfig`.
4. Validación de acceso EKS.
5. Ejecución de validaciones desde `net-utils`.
6. Generación de `report.txt`, `report.json`, `report.html`.
7. Archive/Publish en Jenkins.

## Ejecución local

```bash
chmod +x scripts/*.sh
ENABLE_PING=true ENABLE_TRACEROUTE=false K8S_NAMESPACE=kube-system K8S_POD_NAME=net-utils ./scripts/main.sh config/targets.yaml
```

## Exit codes

- `0`: todo OK
- `1`: errores parciales
- `2`: fallo crítico pipeline
- `3`: dependencias faltantes
- `4`: net-utils no accesible

## Troubleshooting workflow

- Revisar `logs/network_validation.log`.
- Revisar `reports/report.txt` para resumen humano.
- Revisar `reports/report.json` para integración automatizada.
- Compartir `reports/report.html` con SecOps/Networking.

## TODOs estratégicos

- Paralelismo por target/check.
- Retries con backoff por tipo de check.
- Métricas de latencia y availability.
- Notificaciones Slack.
- Integración Prometheus/Pushgateway.
- Multi-cluster support con matriz Jenkins.

## Comandos git iniciales

```bash
git init
git checkout -b main
git add .
git commit -m "chore: bootstrap shell-first network validation pipeline"
git remote add origin <REPO_URL>
git push -u origin main
```
