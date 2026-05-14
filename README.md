# network-validation-pipeline

Pipeline shell-native para troubleshooting de networking post-change en Jenkins + EKS.

## Arquitectura

```text
network-validation-pipeline/
├── Jenkinsfile
├── README.md
├── agents.md
├── codex.profile
├── .gitignore
├── config/
│   └── targets.yaml
├── scripts/
│   ├── main.sh
│   ├── common.sh
│   ├── kubectl_exec.sh
│   ├── dns_check.sh
│   ├── tcp_check.sh
│   ├── http_check.sh
│   ├── tls_check.sh
│   ├── ping_check.sh
│   ├── traceroute_check.sh
│   ├── report_generator.sh
│   └── validate_dependencies.sh
├── reports/
├── logs/
├── templates/
│   └── report_template.html
└── future/
    └── python/
```

## Flujo operativo

1. Jenkins en EC2 hace checkout.
2. Valida dependencias shell locales.
3. Configura kubeconfig con `aws eks update-kubeconfig`.
4. Verifica `kube-system/net-utils`.
5. Ejecuta checks desde el pod con `kubectl exec`.
6. Genera `reports/report.txt`, `reports/report.json`, `reports/report.html`.
7. Publica artefactos y reporte HTML en Jenkins.

## Ejecución de checks desde pod

Todos los checks se ejecutan exclusivamente desde `kube-system/net-utils`:

```bash
kubectl exec -n kube-system net-utils -- sh -c "<comando>"
```

## Dependencias Linux

- awscli
- kubectl
- bash
- awk
- sed
- utilidades dentro del pod `net-utils`: `curl`, `nc`, `dig`, `openssl`, `ping`, `traceroute`
- `jq` opcional para JSON enriquecido

## Ejecución local

```bash
mkdir -p reports logs
ENABLE_PING=true ENABLE_TRACEROUTE=false K8S_NAMESPACE=kube-system K8S_POD_NAME=net-utils scripts/main.sh config/targets.yaml
```

## Targets múltiples y puertos múltiples

El archivo `config/targets.yaml` soporta múltiples objetivos, puertos y secciones opcionales HTTP/TLS. El pipeline continúa aunque fallen checks individuales para acelerar troubleshooting.

## Workflow de troubleshooting

- Ejecutar pipeline post-change.
- Revisar `logs/network_validation.log` para evidencia detallada.
- Compartir `reports/report.txt` con Networking y SecOps.
- Usar `reports/report.html` para revisión ejecutiva rápida.

## TODOs estratégicos

- Paralelismo por tipo de check y por target.
- Retries configurables por check.
- Exportación de métricas técnicas (latencia, errores por tipo).
- Notificaciones Slack por estado y hallazgos críticos.
- Integración con Prometheus Pushgateway.
- Soporte multi-cluster con matriz en Jenkins.

## Comandos git iniciales

```bash
git init
git checkout -b main
git add .
git commit -m "chore: bootstrap shell-first network validation pipeline"
git remote add origin <REPO_URL>
git push -u origin main
```
