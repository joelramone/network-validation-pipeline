from __future__ import annotations

from scripts.models import CheckResult, Target


def run_placeholder_check(target: Target) -> CheckResult:
    # TODO: add parallel execution for high target volumes.
    # TODO: add retry strategy with exponential backoff.
    details = f'Bootstrap check created for protocol={target.protocol} host={target.host}'
    return CheckResult(
        name=target.name,
        check_type=target.protocol,
        target=f'{target.host}:{target.port or ""}'.rstrip(':'),
        status='PASS',
        details=details,
    )


def run_checks(targets: list[Target], enable_ping: bool, enable_traceroute: bool) -> list[CheckResult]:
    selected: list[Target] = []
    for target in targets:
        if target.protocol == 'ping' and not enable_ping:
            continue
        if target.protocol == 'traceroute' and not enable_traceroute:
            continue
        selected.append(target)

    return [run_placeholder_check(target) for target in selected]
