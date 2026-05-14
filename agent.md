# Agent Runtime Guide

Este proyecto usa un enfoque tactical HITL (Human-in-the-Loop):

- Cambios pequeños e incrementales.
- Validación con ejecución real en cada iteración.
- Commits atómicos por capacidad.

## Reglas técnicas

1. Mantener separación de responsabilidades en `scripts/`.
2. Evitar dependencias no justificadas.
3. Toda salida de validación debe persistirse en `reports/` y `logs/`.
4. Mantener compatibilidad con ejecución en Jenkins sobre EC2.
5. No ejecutar checks de red desde Jenkins host; usar `kubectl exec`.

## Roadmap de evolución

- Incorporar ejecución paralela por tipo de check.
- Incorporar retries con políticas configurables.
- Exportar métricas técnicas para observabilidad.
- Integrar notificaciones Slack por resultado de pipeline.
- Agregar soporte multi-cluster desde configuración central.
