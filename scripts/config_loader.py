from __future__ import annotations

from pathlib import Path

import yaml

from scripts.models import Target


def load_targets(file_path: str) -> list[Target]:
    path = Path(file_path)
    if not path.exists():
        raise FileNotFoundError(f'Target file not found: {file_path}')

    with path.open('r', encoding='utf-8') as file:
        raw = yaml.safe_load(file) or {}

    targets_raw = raw.get('targets', [])
    return [Target.model_validate(item) for item in targets_raw]
