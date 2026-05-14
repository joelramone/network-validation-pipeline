from __future__ import annotations

import json
from pathlib import Path

from jinja2 import Environment, FileSystemLoader, select_autoescape

from scripts.models import ValidationReport


def write_json_report(report: ValidationReport, output_file: str) -> None:
    path = Path(output_file)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(report.model_dump_json(indent=2), encoding='utf-8')


def write_html_report(report: ValidationReport, output_file: str) -> None:
    template_env = Environment(
        loader=FileSystemLoader('templates'),
        autoescape=select_autoescape(['html', 'xml']),
    )
    template = template_env.get_template('report_template.html')

    rendered = template.render(
        generated_at=report.generated_at,
        context=report.context,
        checks=[item.model_dump() for item in report.checks],
    )

    path = Path(output_file)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(rendered, encoding='utf-8')
