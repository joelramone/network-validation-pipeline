# Project Agent Rules

## Mission
Entregar troubleshooting de networking rápido, reproducible y auditable para Jenkins + EKS con arquitectura shell-native.

## Mandatory Architecture
- Jenkins actúa solo como orchestration layer y artifact/report collector.
- Todas las pruebas de red deben ejecutarse mediante `kubectl exec` desde `kube-system/net-utils`.
- No ejecutar `curl`, `nc`, `dig`, `openssl`, `ping` ni `traceroute` directamente en Jenkins EC2.

## Directory Conventions
- `scripts/main.sh`: orquestador de ejecución.
- `scripts/common.sh`: logging, timestamps, errores y helpers.
- `scripts/*_check.sh`: checks desacoplados por protocolo.
- `scripts/validate_dependencies.sh`: validación Jenkins + net-utils antes de checks.
- `reports/`: `report.txt`, `report.json`, `report.html`.
- `logs/`: evidencia detallada de ejecución.
- `future/python/`: reservado para evolución futura sin afectar runtime shell actual.

## Coding Rules
- Todo script inicia con `#!/usr/bin/env bash` y `set -euo pipefail`.
- Mantener funciones pequeñas, reutilizables y composables.
- Registrar resultados en formato estructurado y texto legible.
- Continuar ejecución ante fallas de targets individuales.
- Usar exit codes del proyecto: 0,1,2,3,4.
- Prohibido pseudocódigo.

## Operational Rules
- Priorizar simplicidad y debugging en ventanas críticas.
- Evitar lógica compleja embebida en Jenkinsfile.
- Evitar dependencias innecesarias.
- Mantener outputs claros para Networking y SecOps.

## Best Practices
- Validar accesos/dependencias al inicio.
- Mantener stages explícitos y auditables.
- Diseñar scripts ejecutables localmente fuera de Jenkins.
- Evitar sobreingeniería y duplicación de lógica.
