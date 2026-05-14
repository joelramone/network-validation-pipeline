from __future__ import annotations

import logging
import subprocess

LOGGER = logging.getLogger(__name__)


def run_in_pod(namespace: str, pod: str, command: str) -> tuple[int, str, str]:
    kubectl_cmd = [
        'kubectl',
        'exec',
        '-n',
        namespace,
        pod,
        '--',
        'sh',
        '-c',
        command,
    ]
    LOGGER.info('Executing inside pod: %s', command)
    completed = subprocess.run(kubectl_cmd, capture_output=True, text=True, check=False)
    return completed.returncode, completed.stdout.strip(), completed.stderr.strip()
