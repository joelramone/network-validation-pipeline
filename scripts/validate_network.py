from __future__ import annotations

import argparse
import logging
import sys
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parents[1]
if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))

from scripts.checks import run_checks
from scripts.config_loader import load_targets
from scripts.logger_config import setup_logging
from scripts.models import RuntimeConfig, ValidationReport
from scripts.reporting import write_html_report, write_json_report

LOGGER = logging.getLogger(__name__)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description='Bootstrap network validation pipeline runner.')
    parser.add_argument('--targets', required=True, help='Path to targets YAML file')
    parser.add_argument('--namespace', required=True, help='Kubernetes namespace that contains net-utils pod')
    parser.add_argument('--pod', required=True, help='Pod name used to run networking tools')
    parser.add_argument('--enable-ping', default='true', help='Enable ping checks (true/false)')
    parser.add_argument('--enable-traceroute', default='false', help='Enable traceroute checks (true/false)')
    parser.add_argument('--output-json', required=True, help='Path for JSON report output')
    parser.add_argument('--output-html', required=True, help='Path for HTML report output')
    return parser.parse_args()


def str_to_bool(raw: str) -> bool:
    return raw.strip().lower() in {'1', 'true', 'yes', 'y'}


def main() -> int:
    args = parse_args()
    setup_logging()

    runtime = RuntimeConfig(
        targets_file=args.targets,
        namespace=args.namespace,
        pod=args.pod,
        enable_ping=str_to_bool(args.enable_ping),
        enable_traceroute=str_to_bool(args.enable_traceroute),
    )
    LOGGER.info('Runtime config loaded: %s', runtime.model_dump())

    targets = load_targets(runtime.targets_file)
    check_results = run_checks(targets, runtime.enable_ping, runtime.enable_traceroute)

    report = ValidationReport(
        context={
            'cluster': 'provided-by-jenkins-eks-context',
            'namespace': runtime.namespace,
            'pod': runtime.pod,
        },
        checks=check_results,
    )

    write_json_report(report, args.output_json)
    write_html_report(report, args.output_html)

    # TODO: emit Prometheus-compatible metrics output.
    # TODO: add Slack notification adapter for pipeline outcomes.
    # TODO: add multi-cluster orchestration from centralized config.
    LOGGER.info('Reports generated successfully.')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
